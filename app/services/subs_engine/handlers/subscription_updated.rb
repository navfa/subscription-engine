# frozen_string_literal: true

module SubsEngine
  module Handlers
    class SubscriptionUpdated
      include Dry::Monads[:result, :do]

      STATE_MAP = {
        'active' => :active,
        'past_due' => :past_due,
        'canceled' => :canceled,
        'unpaid' => :past_due
      }.freeze

      def call(payload)
        object = payload['object'] || payload[:object]
        subscription = yield find_subscription(object['id'])
        yield sync_state(subscription, object['status'])
        sync_period(subscription, object)
      end

      private

      def find_subscription(stripe_id)
        subscription_repository.find_by_stripe_id(stripe_id).to_result(:subscription_not_found)
      end

      def sync_state(subscription, stripe_status)
        target = STATE_MAP[stripe_status]
        return Success(subscription) unless target
        return Success(subscription) if subscription.current_state == target.to_s

        if subscription.can_transition_to?(target)
          subscription.transition_to(target)
          Success(subscription)
        else
          Failure[:invalid_transition, "Cannot transition to #{target}"]
        end
      end

      def sync_period(subscription, object)
        attrs = {}
        attrs[:current_period_start] = Time.zone.at(object['current_period_start']) if object['current_period_start']
        attrs[:current_period_end] = Time.zone.at(object['current_period_end']) if object['current_period_end']
        subscription.update(attrs) if attrs.any?
        Success(subscription)
      end

      def subscription_repository
        @subscription_repository ||= SubscriptionRepository.new
      end
    end
  end
end
