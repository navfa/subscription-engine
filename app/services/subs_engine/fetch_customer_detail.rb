# frozen_string_literal: true

module SubsEngine
  class FetchCustomerDetail
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :customer_repository, default: -> { CustomerRepository.new }
    option :subscription_repository, default: -> { SubscriptionRepository.new }
    option :invoice_repository, default: -> { InvoiceRepository.new }

    def call(customer_id:)
      @customer_id = customer_id

      find_customer.bind { |customer| build_detail(customer) }
    end

    private

    def find_customer
      customer_repository.find_by_id(@customer_id)
                         .to_result(:customer_not_found)
    end

    def build_detail(customer)
      Success({
        customer: customer,
        subscriptions: subscription_repository.find_active_by_customer(customer),
        invoices: invoice_repository.find_by_customer(customer)
      })
    end
  end
end
