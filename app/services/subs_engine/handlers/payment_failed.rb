# frozen_string_literal: true

module SubsEngine
  module Handlers
    class PaymentFailed
      include Dry::Monads[:result, :do]

      def call(payload)
        object = payload['object'] || payload[:object]
        stripe_sub_id = object['subscription'] || object[:subscription]
        return Success(:no_subscription) unless stripe_sub_id

        subscription = yield find_subscription(stripe_sub_id)
        transition_to_past_due(subscription)
      end

      private

      def find_subscription(stripe_id)
        subscription_repository.find_by_stripe_id(stripe_id).to_result(:subscription_not_found)
      end

      def transition_to_past_due(subscription)
        return Success(subscription) if subscription.current_state == 'past_due'

        if subscription.can_transition_to?(:past_due)
          subscription.transition_to(:past_due)
          Success(subscription)
        else
          Failure[:invalid_transition, 'Cannot transition to past_due']
        end
      end

      def subscription_repository
        @subscription_repository ||= SubscriptionRepository.new
      end
    end
  end
end
