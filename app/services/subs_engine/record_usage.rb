# frozen_string_literal: true

module SubsEngine
  class RecordUsage
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :usage_metric_repository, default: -> { UsageMetricRepository.new }

    def call(customer:, metric_code:, quantity:, recorded_at: Time.current, metadata: {})
      @customer = customer
      @quantity = quantity
      @recorded_at = recorded_at
      @metadata = metadata

      validate_quantity.bind do
        find_metric(metric_code).bind do |metric|
          persist_record(metric)
        end
      end
    end

    private

    def validate_quantity
      @quantity.positive? ? Success(@quantity) : Failure[:invalid_quantity, @quantity]
    end

    def find_metric(code)
      usage_metric_repository.find_active_by_code(code).to_result(:unknown_metric)
    end

    def persist_record(metric)
      record = UsageRecord.create(
        customer: @customer,
        usage_metric: metric,
        quantity: @quantity,
        recorded_at: @recorded_at,
        metadata: @metadata
      )
      record.persisted? ? Success(record) : Failure[:persistence_failed, record.errors.full_messages]
    end
  end
end
