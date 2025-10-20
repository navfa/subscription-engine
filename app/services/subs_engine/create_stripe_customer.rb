# frozen_string_literal: true

module SubsEngine
  class CreateStripeCustomer
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :gateway, default: -> { StripeGateway.new }

    def call(customer)
      @customer = customer

      validate_not_connected.bind do
        create_on_stripe.bind do |stripe_customer|
          persist_stripe_id(stripe_customer)
        end
      end
    end

    private

    def validate_not_connected
      return Failure[:already_connected, @customer] if @customer.stripe_connected?

      Success(@customer)
    end

    def create_on_stripe
      gateway.create_customer(
        email: @customer.email,
        metadata: { subs_engine_id: @customer.id }
      )
    end

    def persist_stripe_id(stripe_customer)
      @customer.update(stripe_customer_id: stripe_customer.id)
      Success(@customer)
    end
  end
end
