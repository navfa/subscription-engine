# frozen_string_literal: true

module SubsEngine
  class CustomerRepository
    include Dry::Monads[:maybe]

    def find_by_external_id(external_id)
      Maybe(Customer.find_by(external_id: external_id))
    end

    def find_by_stripe_id(stripe_customer_id)
      Maybe(Customer.find_by(stripe_customer_id: stripe_customer_id))
    end

    def find_by_email(email)
      Maybe(Customer.find_by(email: email))
    end
  end
end
