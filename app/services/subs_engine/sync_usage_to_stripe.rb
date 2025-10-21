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
      @synced = []

      sync_active_metrics
    end

    private

    def sync_active_metrics
      usage_metric_repository.find_active.each do |metric|
        sync_metric(metric)
      end

      Success(@synced)
    end

    def sync_metric(metric)
      total = usage_repository.sum_by_metric(
        @subscription.customer, metric,
        @subscription.current_period_start, @subscription.current_period_end
      )

      report_to_stripe(metric, total) if total.positive?
    end

    def report_to_stripe(metric, total)
      gateway.report_usage(
        subscription_item_id: @subscription.stripe_subscription_item_id,
        quantity: total,
        timestamp: @subscription.current_period_start.to_i
      ).bind do
        @synced << { metric: metric.code, quantity: total }
        Success(total)
      end
    end
  end
end
