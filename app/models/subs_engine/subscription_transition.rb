# frozen_string_literal: true

module SubsEngine
  class SubscriptionTransition < ApplicationRecord
    belongs_to :subscription, inverse_of: :transitions

    validates :to_state, presence: true

    after_destroy :update_most_recent, if: :most_recent?

    private

    def update_most_recent
      last_transition = subscription.transitions.order(:sort_key).last
      return unless last_transition

      last_transition.update_column(:most_recent, true)
    end
  end
end
