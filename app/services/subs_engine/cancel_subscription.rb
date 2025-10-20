# frozen_string_literal: true

module SubsEngine
  class CancelSubscription
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :gateway, default: -> { StripeGateway.new }

    def call(subscription)
      @subscription = subscription

      validate_cancelable
        .bind { cancel_on_stripe }
        .bind { transition_to_canceled }
        .bind { persist_canceled_at }
    end

    private

    def validate_cancelable
      return Failure[:already_canceled, @subscription] unless @subscription.can_transition_to?(:canceled)

      Success(@subscription)
    end

    def cancel_on_stripe
      return Success(nil) unless @subscription.stripe_subscription_id

      gateway.cancel_subscription(stripe_subscription_id: @subscription.stripe_subscription_id)
    end

    def transition_to_canceled
      if @subscription.transition_to(:canceled)
        Success(@subscription)
      else
        Failure[:transition_failed, @subscription]
      end
    end

    def persist_canceled_at
      @subscription.update(canceled_at: Time.current)
      Success(@subscription)
    end
  end
end
