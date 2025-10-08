# frozen_string_literal: true

module SubsEngine
  class StripeGateway
    include Dry::Monads[:result, :try]

    def create_customer(email:, metadata: {})
      stripe_call { Stripe::Customer.create(email: email, metadata: metadata) }
    end

    def create_subscription(customer_id:, price_id:, metadata: {})
      stripe_call do
        Stripe::Subscription.create(
          customer: customer_id,
          items: [{ price: price_id }],
          metadata: metadata
        )
      end
    end

    def cancel_subscription(stripe_subscription_id:, prorate: true)
      stripe_call do
        Stripe::Subscription.cancel(
          stripe_subscription_id,
          prorate: prorate
        )
      end
    end

    private

    def stripe_call(&block)
      Try[Stripe::StripeError, &block]
        .to_result
        .or { |error| Failure[:stripe_error, error.message] }
    end
  end
end
