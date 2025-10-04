# frozen_string_literal: true

module SubsEngine
  class CreateStripeCustomer
    include Dry::Monads[:result, :do]

    def call(customer)
      yield validate_not_connected(customer)
      stripe_customer = yield create_on_stripe(customer)
      persist_stripe_id(customer, stripe_customer)
    end

    private

    def validate_not_connected(customer)
      return Failure(:already_connected) if customer.stripe_connected?

      Success(customer)
    end

    def create_on_stripe(customer)
      gateway.create_customer(email: customer.email, metadata: { subs_engine_id: customer.id })
    end

    def persist_stripe_id(customer, stripe_customer)
      customer.update(stripe_customer_id: stripe_customer.id)
      Success(customer)
    end

    def gateway
      @gateway ||= StripeGateway.new
    end
  end
end
