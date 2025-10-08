# frozen_string_literal: true

module SubsEngine
  class CreateStripeCustomer
    include Dry::Monads[:result, :do]

    def call(customer, gateway: StripeGateway.new)
      yield validate_not_connected(customer)
      stripe_customer = yield gateway.create_customer(
        email: customer.email,
        metadata: { subs_engine_id: customer.id }
      )
      persist_stripe_id(customer, stripe_customer)
    end

    private

    def validate_not_connected(customer)
      return Failure[:already_connected, customer] if customer.stripe_connected?

      Success(customer)
    end

    def persist_stripe_id(customer, stripe_customer)
      customer.update(stripe_customer_id: stripe_customer.id)
      Success(customer)
    end
  end
end
