# frozen_string_literal: true

module SubsEngine
  class FakeGateway
    include Dry::Monads[:result]

    FakeStripeObject = Struct.new(:id, :items, keyword_init: true)
    FakeItems = Struct.new(:data, keyword_init: true)
    FakeItem = Struct.new(:id, keyword_init: true)

    def create_customer(email:, metadata: {})
      Success(FakeStripeObject.new(id: "cus_fake_#{SecureRandom.hex(8)}"))
    end

    def create_subscription(customer_id:, price_id:, metadata: {})
      item = FakeItem.new(id: "si_fake_#{SecureRandom.hex(8)}")
      Success(FakeStripeObject.new(
        id: "sub_fake_#{SecureRandom.hex(8)}",
        items: FakeItems.new(data: [item])
      ))
    end

    def update_subscription(stripe_subscription_id:, new_price_id:, prorate: true)
      Success(FakeStripeObject.new(id: stripe_subscription_id))
    end

    def cancel_subscription(stripe_subscription_id:, prorate: true)
      Success(FakeStripeObject.new(id: stripe_subscription_id))
    end

    def retrieve_invoice(stripe_invoice_id:)
      Success(FakeStripeObject.new(id: stripe_invoice_id))
    end

    def report_usage(subscription_item_id:, quantity:, timestamp: Time.current.to_i)
      Success(true)
    end
  end
end
