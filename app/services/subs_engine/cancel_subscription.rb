# frozen_string_literal: true

module SubsEngine
  class CancelSubscription
    include Dry::Monads[:result, :do]

    def call(subscription, gateway: StripeGateway.new)
      yield validate_cancelable(subscription)
      yield cancel_on_stripe(subscription, gateway)
      yield transition_to_canceled(subscription)
      persist_canceled_at(subscription)
    end

    private

    def validate_cancelable(subscription)
      return Failure[:already_canceled, subscription] unless subscription.can_transition_to?(:canceled)

      Success(subscription)
    end

    def cancel_on_stripe(subscription, gateway)
      return Success(nil) unless subscription.stripe_subscription_id

      gateway.cancel_subscription(stripe_subscription_id: subscription.stripe_subscription_id)
    end

    def transition_to_canceled(subscription)
      if subscription.transition_to(:canceled)
        Success(subscription)
      else
        Failure[:transition_failed, subscription]
      end
    end

    def persist_canceled_at(subscription)
      subscription.update(canceled_at: Time.current)
      Success(subscription)
    end
  end
end
