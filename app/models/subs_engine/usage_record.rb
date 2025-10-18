# frozen_string_literal: true

module SubsEngine
  class UsageRecord < ApplicationRecord
    belongs_to :customer
    belongs_to :usage_metric

    validates :quantity, presence: true, numericality: { greater_than: 0 }
    validates :recorded_at, presence: true

    # Append-only: prevent updates to persisted records
    before_update { throw(:abort) }

    scope :for_period, ->(start_at, end_at) { where(recorded_at: start_at..end_at) }
    scope :for_metric, ->(metric) { where(usage_metric: metric) }
    scope :for_customer, ->(customer) { where(customer: customer) }
  end
end
