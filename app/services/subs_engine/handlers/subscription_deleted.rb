# frozen_string_literal: true

module SubsEngine
  module Handlers
    class SubscriptionDeleted
      include Dry::Monads[:result, :do]

      def call(payload)
        object = payload['object'] || payload[:object]
        subscription = yield find_subscription(object['id'])
        yield cancel(subscription)
        persist_canceled_at(subscription)
      end

      private

      def find_subscription(stripe_id)
        subscription_repository.find_by_stripe_id(stripe_id).to_result(:subscription_not_found)
      end

      def cancel(subscription)
        return Success(subscription) if subscription.current_state == 'canceled'

        if subscription.can_transition_to?(:canceled)
          subscription.transition_to(:canceled)
          Success(subscription)
        else
          Failure[:invalid_transition, 'Cannot transition to canceled']
        end
      end

      def persist_canceled_at(subscription)
        subscription.update(canceled_at: Time.current)
        Success(subscription)
      end

      def subscription_repository
        @subscription_repository ||= SubscriptionRepository.new
      end
    end
  end
end
