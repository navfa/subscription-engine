# frozen_string_literal: true

module SubsEngine
  class SubscriptionStatusComponent < ViewComponent::Base
    STATE_STYLES = {
      'trialing' => 'subs-badge subs-badge--trialing',
      'active' => 'subs-badge subs-badge--active',
      'past_due' => 'subs-badge subs-badge--past-due',
      'canceled' => 'subs-badge subs-badge--canceled',
      'expired' => 'subs-badge subs-badge--expired'
    }.freeze

    STATE_LABELS = {
      'trialing' => 'Trialing',
      'active' => 'Active',
      'past_due' => 'Past Due',
      'canceled' => 'Canceled',
      'expired' => 'Expired'
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
