# frozen_string_literal: true

module SubsEngine
  class SubscribeCustomer
    include Dry::Monads[:result, :do]

    def call(customer:, plan:, gateway: StripeGateway.new)
      yield validate_plan_active(plan)
      yield validate_no_active_subscription(customer)
      yield ensure_stripe_customer(customer, gateway)
      stripe_sub = yield create_on_stripe(customer, plan, gateway)
      subscription = yield persist_subscription(customer, plan, stripe_sub)
      activate(subscription, stripe_sub)
    end

    private

    def validate_plan_active(plan)
      plan.active? ? Success(plan) : Failure[:plan_inactive, plan]
    end

    def validate_no_active_subscription(customer)
      active = subscription_repository.find_active_by_customer(customer)
      active.exists? ? Failure[:already_subscribed, customer] : Success(customer)
    end

    def ensure_stripe_customer(customer, gateway)
      return Success(customer) if customer.stripe_connected?

      CreateStripeCustomer.new.call(customer, gateway: gateway)
    end

    def create_on_stripe(customer, plan, gateway)
      gateway.create_subscription(
        customer_id: customer.stripe_customer_id,
        price_id: plan.stripe_price_id,
        metadata: { subs_engine_plan_id: plan.id }
      )
    end

    def persist_subscription(customer, plan, stripe_sub)
      subscription = Subscription.new(
        customer: customer,
        plan: plan,
        stripe_subscription_id: stripe_sub.id,
        current_period_start: Time.current,
        current_period_end: 1.month.from_now
      )

      if subscription.save
        Success(subscription)
      else
        Failure[:persistence_failed, subscription]
      end
    end

    def activate(subscription, stripe_sub)
      subscription.transition_to(:active, stripe_subscription_id: stripe_sub.id)
      Success(subscription)
    end

    def subscription_repository
      @subscription_repository ||= SubscriptionRepository.new
    end
  end
end
