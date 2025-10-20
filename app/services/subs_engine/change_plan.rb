# frozen_string_literal: true

module SubsEngine
  class ChangePlan
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :gateway, default: -> { StripeGateway.new }

    def call(subscription:, new_plan:)
      @subscription = subscription
      @new_plan = new_plan

      validate_different_plan
        .bind { validate_plan_active }
        .bind { validate_subscription_active }
        .bind { update_on_stripe }
        .bind { persist_plan_change }
    end

    private

    def validate_different_plan
      return Failure[:same_plan, @subscription] if @subscription.plan_id == @new_plan.id

      Success(@subscription)
    end

    def validate_plan_active
      @new_plan.active? ? Success(@new_plan) : Failure[:plan_inactive, @new_plan]
    end

    def validate_subscription_active
      return Success(@subscription) if @subscription.current_state == SubscriptionStateMachine::ACTIVE

      Failure[:subscription_not_active, @subscription]
    end

    def update_on_stripe
      gateway.update_subscription(
        stripe_subscription_id: @subscription.stripe_subscription_id,
        new_price_id: @new_plan.stripe_price_id
      )
    end

    def persist_plan_change
      @subscription.update(plan: @new_plan) ? Success(@subscription) : Failure[:persistence_failed, @subscription]
    end
  end
end
