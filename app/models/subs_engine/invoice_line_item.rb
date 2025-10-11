# frozen_string_literal: true

module SubsEngine
  class InvoiceLineItem < ApplicationRecord
    belongs_to :invoice

    enum :line_type, { subscription: 0, proration: 1, usage: 2 }

    validates :description, presence: true
    validates :amount_cents, presence: true
    validates :quantity, presence: true, numericality: { greater_than: 0 }
  end
end
