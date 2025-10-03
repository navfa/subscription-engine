# frozen_string_literal: true

module SubsEngine
  class SubscriptionStateMachine
    include Statesman::Machine

    state :trialing, initial: true
    state :active
    state :past_due
    state :canceled
    state :expired

    transition from: :trialing, to: [:active, :canceled]
    transition from: :active,   to: [:past_due, :canceled]
    transition from: :past_due, to: [:active, :canceled, :expired]
    transition from: :canceled, to: [:expired]
  end
end
