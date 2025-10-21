# frozen_string_literal: true

module SubsEngine
  module Handlers
    class SubscriptionUpdated
      extend Dry::Initializer
      include Dry::Monads[:result]

      STATE_MAP = {
        SubscriptionStateMachine::ACTIVE => :active,
        SubscriptionStateMachine::PAST_DUE => :past_due,
        SubscriptionStateMachine::CANCELED => :canceled,
        'unpaid' => :past_due
      }.freeze

      option :subscription_repository, default: -> { SubscriptionRepository.new }

      def call(payload)
        @object = payload['object'] || payload[:object]

        find_subscription
          .bind { |sub| sync_state(sub) }
          .bind { |sub| sync_period(sub) }
      end

      private

      def find_subscription
        subscription_repository.find_by_stripe_id(@object['id'])
                               .to_result(:subscription_not_found)
      end

      def sync_state(subscription)
        target = STATE_MAP[@object['status']]
        return Success(subscription) unless target
        return Success(subscription) if subscription.current_state == target.to_s

        if subscription.can_transition_to?(target)
          subscription.transition_to(target)
          Success(subscription)
        else
          Failure[:invalid_transition, "Cannot transition to #{target}"]
        end
      end

      def sync_period(subscription)
        attrs = {}
        attrs[:current_period_start] = Time.zone.at(@object['current_period_start']) if @object['current_period_start']
        attrs[:current_period_end] = Time.zone.at(@object['current_period_end']) if @object['current_period_end']
        subscription.update(attrs) if attrs.any?
        Success(subscription)
      end
    end
  end
end
