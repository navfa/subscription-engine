# frozen_string_literal: true

module SubsEngine
  module Handlers
    class PaymentSucceeded
      include Dry::Monads[:result]

      def call(payload)
        object = payload['object'] || payload[:object]
        stripe_sub_id = object['subscription'] || object[:subscription]
        return Success(:no_subscription) unless stripe_sub_id

        subscription_repository.find_by_stripe_id(stripe_sub_id)
                               .to_result(:subscription_not_found)
                               .fmap { |sub| sub }
      end

      private

      def subscription_repository
        @subscription_repository ||= SubscriptionRepository.new
      end
    end
  end
end
