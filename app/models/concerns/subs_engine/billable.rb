# frozen_string_literal: true

module SubsEngine
  module Billable
    extend ActiveSupport::Concern

    included do
      has_one :billing_customer, class_name: 'SubsEngine::Customer',
                                 foreign_key: :external_id,
                                 primary_key: :id,
                                 dependent: :destroy,
                                 inverse_of: false
    end

    def billing_subscriptions
      return SubsEngine::Subscription.none unless billing_customer

      billing_customer.subscriptions
    end

    def active_subscription
      billing_subscriptions.merge(SubsEngine::Subscription.in_state(:active)).first
    end

    def subscribed?
      active_subscription.present?
    end
  end
end
