# frozen_string_literal: true

module SubsEngine
  class Customer < ApplicationRecord
    validates :external_id, presence: true, uniqueness: true
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :stripe_customer_id, uniqueness: true, allow_nil: true

    scope :with_stripe, -> { where.not(stripe_customer_id: nil) }

    def stripe_connected?
      stripe_customer_id.present?
    end
  end
end
