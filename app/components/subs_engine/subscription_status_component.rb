# frozen_string_literal: true

module SubsEngine
  class SubscriptionStatusComponent < ViewComponent::Base
    STATE_STYLES = {
      SubscriptionStateMachine::TRIALING => 'subs-badge subs-badge--trialing',
      SubscriptionStateMachine::ACTIVE => 'subs-badge subs-badge--active',
      SubscriptionStateMachine::PAST_DUE => 'subs-badge subs-badge--past-due',
      SubscriptionStateMachine::CANCELED => 'subs-badge subs-badge--canceled',
      SubscriptionStateMachine::EXPIRED => 'subs-badge subs-badge--expired'
    }.freeze

    STATE_LABELS = {
      SubscriptionStateMachine::TRIALING => 'Trialing',
      SubscriptionStateMachine::ACTIVE => 'Active',
      SubscriptionStateMachine::PAST_DUE => 'Past Due',
      SubscriptionStateMachine::CANCELED => 'Canceled',
      SubscriptionStateMachine::EXPIRED => 'Expired'
    }.freeze

    attr_reader :subscription

    def initialize(subscription:)
      super
      @subscription = subscription
    end

    def state
      subscription.current_state
    end

    def badge_class
      STATE_STYLES.fetch(state, 'subs-badge')
    end

    def label
      STATE_LABELS.fetch(state, state.to_s.humanize)
    end

    def cancelable?
      subscription.can_transition_to?(:canceled)
    end
  end
end
