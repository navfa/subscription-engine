# frozen_string_literal: true

module SubsEngine
  class SubscribeCustomer
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :gateway, default: -> { StripeGateway.new }
    option :subscription_repository, default: -> { SubscriptionRepository.new }

    def call(customer:, plan:)
      @customer = customer
      @plan = plan

      validate_plan_active
        .bind { validate_no_active_subscription }
        .bind { ensure_stripe_customer }
        .bind { create_on_stripe }
        .bind { |stripe_sub| persist_subscription(stripe_sub) }
        .bind { activate }
    end

    private

    def validate_plan_active
      @plan.active? ? Success(@plan) : Failure[:plan_inactive, @plan]
    end

    def validate_no_active_subscription
      active = subscription_repository.find_active_by_customer(@customer)
      active.exists? ? Failure[:already_subscribed, @customer] : Success(@customer)
    end

    def ensure_stripe_customer
      return Success(@customer) if @customer.stripe_connected?

      CreateStripeCustomer.new(gateway: gateway).call(@customer)
    end

    def create_on_stripe
      gateway.create_subscription(
        customer_id: @customer.stripe_customer_id,
        price_id: @plan.stripe_price_id,
        metadata: { subs_engine_plan_id: @plan.id }
      )
    end

    def persist_subscription(stripe_sub)
      @stripe_sub = stripe_sub
      subscription = Subscription.new(
        customer: @customer,
        plan: @plan,
        stripe_subscription_id: stripe_sub.id,
        stripe_subscription_item_id: stripe_sub.items.data[0].id,
        current_period_start: Time.current,
        current_period_end: 1.month.from_now
      )

      if subscription.save
        @subscription = subscription
        Success(subscription)
      else
        Failure[:persistence_failed, subscription]
      end
    end

    def activate
      @subscription.transition_to(:active, stripe_subscription_id: @stripe_sub.id)
      Success(@subscription)
    end
  end
end
