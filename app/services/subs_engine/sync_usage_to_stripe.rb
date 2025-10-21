# frozen_string_literal: true

module SubsEngine
  class SyncUsageToStripe
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :gateway, default: -> { StripeGateway.new }
    option :usage_metric_repository, default: -> { UsageMetricRepository.new }
    option :usage_repository, default: -> { UsageRepository.new }

    def call(subscription)
      @subscription = subscription

      sync_active_metrics
    end

    private

    def sync_active_metrics
      results = usage_metric_repository.find_active.filter_map do |metric|
        aggregate_and_report(metric)
      end

      Success(results)
    end

    def aggregate_and_report(metric)
      total = usage_repository.sum_by_metric(
        @subscription.customer, metric,
        @subscription.current_period_start, @subscription.current_period_end
      )

      return unless total.positive?

      report_to_stripe(metric, total).value_or(nil)
    end

    def report_to_stripe(metric, total)
      gateway.report_usage(
        subscription_item_id: @subscription.stripe_subscription_item_id,
        quantity: total,
        timestamp: @subscription.current_period_start.to_i
      ).fmap { { metric: metric.code, quantity: total } }
    end
  end
end
