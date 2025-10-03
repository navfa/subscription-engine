# frozen_string_literal: true

module SubsEngine
  class Subscription < ApplicationRecord
    include Statesman::Adapters::ActiveRecordQueries[
      transition_class: SubscriptionTransition,
      initial_state: :trialing
    ]

    belongs_to :customer
    belongs_to :plan
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
