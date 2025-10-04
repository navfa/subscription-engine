# frozen_string_literal: true

module SubsEngine
  class StripeGateway
    include Dry::Monads[:result, :try]

    def create_customer(email:, metadata: {})
      result = Try[Stripe::StripeError] do
        Stripe::Customer.create(email: email, metadata: metadata)
      end

      result.to_result.or { |error| Failure(stripe_error: error.message) }
    end
  end
end
