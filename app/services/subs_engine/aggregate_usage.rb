# frozen_string_literal: true

module SubsEngine
  class AggregateUsage
    include Dry::Monads[:result, :do]

    def call(customer:, metric_code:, period_start:, period_end:)
      metric = yield find_metric(metric_code)
      total = usage_repository.sum_by_metric(customer, metric, period_start, period_end)
      Success({ metric: metric, quantity: total, period_start: period_start, period_end: period_end })
    end

    private

    def find_metric(code)
      metric = UsageMetric.find_by(code: code)
      metric ? Success(metric) : Failure[:unknown_metric, code]
    end

    def usage_repository
      @usage_repository ||= UsageRepository.new
    end
  end
end
