# frozen_string_literal: true

module SubsEngine
  class ChangePlan
    include Dry::Monads[:result, :do]

    def call(subscription:, new_plan:, gateway: StripeGateway.new)
      yield validate_different_plan(subscription, new_plan)
      yield validate_plan_active(new_plan)
      yield validate_subscription_active(subscription)
      yield update_on_stripe(subscription, new_plan, gateway)
      persist_plan_change(subscription, new_plan)
    end

    private

    def validate_different_plan(subscription, new_plan)
      return Failure[:same_plan, subscription] if subscription.plan_id == new_plan.id

      Success(subscription)
    end

    def validate_plan_active(plan)
      plan.active? ? Success(plan) : Failure[:plan_inactive, plan]
    end

    def validate_subscription_active(subscription)
      return Success(subscription) if subscription.current_state == 'active'

      Failure[:subscription_not_active, subscription]
    end

    def update_on_stripe(subscription, new_plan, gateway)
      gateway.update_subscription(
        stripe_subscription_id: subscription.stripe_subscription_id,
        new_price_id: new_plan.stripe_price_id
      )
    end

    def persist_plan_change(subscription, new_plan)
      subscription.update(plan: new_plan) ? Success(subscription) : Failure[:persistence_failed, subscription]
    end
  end
end
