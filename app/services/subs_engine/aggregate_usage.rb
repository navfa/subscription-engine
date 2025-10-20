# frozen_string_literal: true

module SubsEngine
  class AggregateUsage
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :usage_metric_repository, default: -> { UsageMetricRepository.new }
    option :usage_repository, default: -> { UsageRepository.new }

    def call(customer:, metric_code:, period_start:, period_end:)
      @customer = customer
      @period_start = period_start
      @period_end = period_end

      find_metric(metric_code).bind do |metric|
        build_aggregate(metric)
      end
    end

    private

    def find_metric(code)
      usage_metric_repository.find_by_code(code).to_result(:unknown_metric)
    end

    def build_aggregate(metric)
      total = usage_repository.sum_by_metric(@customer, metric, @period_start, @period_end)
      Success({ metric: metric, quantity: total, period_start: @period_start, period_end: @period_end })
    end
  end
end
