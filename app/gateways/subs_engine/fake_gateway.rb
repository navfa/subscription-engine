# frozen_string_literal: true

module SubsEngine
  class FakeGateway
    include Dry::Monads[:result]

    FakeStripeObject = Struct.new(:id, :items)
    FakeItems = Struct.new(:data)
    FakeItem = Struct.new(:id)

    def create_customer(email:, metadata: {}) # rubocop:disable Lint/UnusedMethodArgument
      Success(FakeStripeObject.new("cus_fake_#{SecureRandom.hex(8)}"))
    end

    def create_subscription(customer_id:, price_id:, metadata: {}) # rubocop:disable Lint/UnusedMethodArgument
      item = FakeItem.new("si_fake_#{SecureRandom.hex(8)}")
      Success(FakeStripeObject.new(
                "sub_fake_#{SecureRandom.hex(8)}",
                FakeItems.new([item])
              ))
    end

    def update_subscription(stripe_subscription_id:, **_opts)
      Success(FakeStripeObject.new(stripe_subscription_id))
    end

    def cancel_subscription(stripe_subscription_id:, **_opts)
      Success(FakeStripeObject.new(stripe_subscription_id))
    end

    def retrieve_invoice(stripe_invoice_id:)
      Success(FakeStripeObject.new(stripe_invoice_id))
    end

    def report_usage(**_opts)
      Success(true)
    end
  end
end
