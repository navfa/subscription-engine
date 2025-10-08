# frozen_string_literal: true

module SubsEngine
  class StripeGateway
    include Dry::Monads[:result, :try]

    def create_customer(email:, metadata: {})
      stripe_call { Stripe::Customer.create(email: email, metadata: metadata) }
    end

    private

    def stripe_call(&block)
      Try[Stripe::StripeError, &block]
        .to_result
        .or { |error| Failure[:stripe_error, error.message] }
    end
  end
end
