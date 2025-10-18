# frozen_string_literal: true

module SubsEngine
  class UsageMetric < ApplicationRecord
    has_many :usage_records, dependent: :restrict_with_error

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :unit, presence: true

    scope :active, -> { where(active: true) }
  end
end
