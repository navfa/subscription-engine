# frozen_string_literal: true

module SubsEngine
  class UsageMetricRepository
    include Dry::Monads[:maybe]

    def find_by_code(code)
      Maybe(UsageMetric.find_by(code: code))
    end

    def find_active_by_code(code)
      Maybe(UsageMetric.active.find_by(code: code))
    end

    def find_active
      UsageMetric.active.order(:name)
    end
  end
end
