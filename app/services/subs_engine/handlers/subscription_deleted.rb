# frozen_string_literal: true

module SubsEngine
  module Handlers
    class SubscriptionDeleted
      extend Dry::Initializer
      include Dry::Monads[:result]

      option :subscription_repository, default: -> { SubscriptionRepository.new }

      def call(payload)
        @object = payload['object'] || payload[:object]

        find_subscription
          .bind { cancel }
          .bind { persist_canceled_at }
      end

      private

      def find_subscription
        subscription_repository.find_by_stripe_id(@object['id']).to_result(:subscription_not_found).bind do |sub|
          @subscription = sub
          Success(sub)
        end
      end

      def cancel
        return Success(@subscription) if @subscription.current_state == SubscriptionStateMachine::CANCELED

        if @subscription.can_transition_to?(:canceled)
          @subscription.transition_to(:canceled)
          Success(@subscription)
        else
          Failure[:invalid_transition, 'Cannot transition to canceled']
        end
      end

      def persist_canceled_at
        @subscription.update(canceled_at: Time.current)
        Success(@subscription)
      end
    end
  end
end
