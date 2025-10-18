# frozen_string_literal: true

module SubsEngine
  class RecordUsage
    include Dry::Monads[:result, :do]

    def call(customer:, metric_code:, quantity:, recorded_at: Time.current, metadata: {})
      metric = yield find_metric(metric_code)
      yield validate_quantity(quantity)
      persist_record(customer, metric, quantity, recorded_at, metadata)
    end

    private

    def find_metric(code)
      metric = UsageMetric.active.find_by(code: code)
      metric ? Success(metric) : Failure[:unknown_metric, code]
    end

    def validate_quantity(quantity)
      quantity.positive? ? Success(quantity) : Failure[:invalid_quantity, quantity]
    end

    def persist_record(customer, metric, quantity, recorded_at, metadata)
      record = UsageRecord.create(
        customer: customer,
        usage_metric: metric,
        quantity: quantity,
        recorded_at: recorded_at,
        metadata: metadata
      )
      record.persisted? ? Success(record) : Failure[:persistence_failed, record.errors.full_messages]
    end
  end
end
