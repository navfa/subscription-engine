# frozen_string_literal: true

module SubsEngine
  class Plan < ApplicationRecord
    enum :interval, { monthly: 0, yearly: 1 }

    validates :name, presence: true
    validates :slug, presence: true, uniqueness: true
    validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :currency, presence: true, length: { is: 3 }

    scope :active, -> { where(active: true) }
  end
end
