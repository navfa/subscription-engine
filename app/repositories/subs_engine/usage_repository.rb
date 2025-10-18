# frozen_string_literal: true

module SubsEngine
  class UsageRepository
    include Dry::Monads[:maybe]

    def find_by_customer_and_period(customer, metric, start_at, end_at)
      UsageRecord.for_customer(customer)
                 .for_metric(metric)
                 .for_period(start_at, end_at)
                 .includes(:usage_metric)
                 .order(recorded_at: :desc)
    end

    def sum_by_metric(customer, metric, start_at, end_at)
      UsageRecord.for_customer(customer)
                 .for_metric(metric)
                 .for_period(start_at, end_at)
                 .sum(:quantity)
    end

    def find_by_customer(customer, limit: 50)
      UsageRecord.for_customer(customer)
                 .includes(:usage_metric)
                 .order(recorded_at: :desc)
                 .limit(limit)
    end
  end
end
