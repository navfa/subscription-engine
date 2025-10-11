# frozen_string_literal: true

module SubsEngine
  class Invoice < ApplicationRecord
    belongs_to :customer
    belongs_to :subscription, optional: true
    has_many :line_items, class_name: 'SubsEngine::InvoiceLineItem', dependent: :destroy

    enum :status, { draft: 0, open: 1, paid: 2, void: 3, uncollectible: 4 }

    validates :amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :currency, presence: true, length: { is: 3 }

    scope :recent, ->(limit = 10) { order(created_at: :desc).limit(limit) }
  end
end
