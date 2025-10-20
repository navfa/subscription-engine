# frozen_string_literal: true

module SubsEngine
  module Handlers
    class PaymentFailed
      extend Dry::Initializer
      include Dry::Monads[:result]

      option :subscription_repository, default: -> { SubscriptionRepository.new }

      def call(payload)
        @object = payload['object'] || payload[:object]
        @stripe_sub_id = @object['subscription'] || @object[:subscription]

        return Success(:no_subscription) unless @stripe_sub_id

        find_subscription.bind do
          transition_to_past_due
        end
      end

      private

      def find_subscription
        subscription_repository.find_by_stripe_id(@stripe_sub_id).to_result(:subscription_not_found).bind do |sub|
          @subscription = sub
          Success(sub)
        end
      end

      def transition_to_past_due
        return Success(@subscription) if @subscription.current_state == SubscriptionStateMachine::PAST_DUE

        if @subscription.can_transition_to?(:past_due)
          @subscription.transition_to(:past_due)
          Success(@subscription)
        else
          Failure[:invalid_transition, 'Cannot transition to past_due']
        end
      end
    end
  end
end
