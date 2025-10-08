# frozen_string_literal: true

module SubsEngine
  class SubscriptionRepository
    include Dry::Monads[:maybe]

    def find_by_id(id)
      Maybe(Subscription.find_by(id: id))
    end

    def find_active_by_customer(customer)
      Subscription.where(customer: customer).in_state(:active)
    end

    def find_by_stripe_id(stripe_subscription_id)
      Maybe(Subscription.find_by(stripe_subscription_id: stripe_subscription_id))
    end
  end
end
