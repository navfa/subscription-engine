# frozen_string_literal: true

module SubsEngine
  class Subscription < ApplicationRecord
    include Statesman::Adapters::ActiveRecordQueries[
      transition_class: SubscriptionTransition,
      initial_state: :trialing
    ]

    include Turbo::Broadcastable

    belongs_to :customer
    belongs_to :plan

    after_create_commit -> { broadcast_prepend_later_to('subs_engine_subscriptions') }
    after_update_commit -> { broadcast_replace_later_to('subs_engine_subscriptions') }
    has_many :transitions, class_name: 'SubsEngine::SubscriptionTransition',
                           dependent: :destroy,
                           autosave: false

    delegate :current_state, :can_transition_to?, to: :state_machine

    def state_machine
      @state_machine ||= SubscriptionStateMachine.new(
        self,
        transition_class: SubscriptionTransition,
        association_name: :transitions
      )
    end

    def transition_to(state, metadata = {})
      state_machine.transition_to(state, metadata)
    end

    def transition_to!(state, metadata = {})
      state_machine.transition_to!(state, metadata)
    end
  end
end
