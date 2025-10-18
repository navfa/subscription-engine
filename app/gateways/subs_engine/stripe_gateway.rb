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

    def update_subscription(stripe_subscription_id:, new_price_id:, prorate: true)
      stripe_call do
        sub = Stripe::Subscription.retrieve(stripe_subscription_id)
        Stripe::Subscription.update(
          stripe_subscription_id,
          items: [{ id: sub.items.data[0].id, price: new_price_id }],
          proration_behavior: prorate ? 'create_prorations' : 'none'
        )
      end
    end

    def retrieve_invoice(stripe_invoice_id:)
      stripe_call { Stripe::Invoice.retrieve(stripe_invoice_id) }
    end

    def report_usage(subscription_item_id:, quantity:, timestamp: Time.current.to_i)
      stripe_call do
        Stripe::SubscriptionItem.create_usage_record(
          subscription_item_id,
          quantity: quantity,
          timestamp: timestamp,
          action: 'set'
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
