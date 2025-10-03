# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SubscriptionStateMachine do
  describe 'states' do
    it 'defines all expected states' do
      expected = %w[trialing active past_due canceled expired]
      expect(described_class.states).to match_array(expected)
    end

    it 'uses trialing as the initial state' do
      subscription = create(:subscription)
      expect(subscription.current_state).to eq('trialing')
    end
  end

  describe 'allowed transitions' do
    let(:valid_transitions) do
      {
        'trialing' => %w[active canceled],
        'active' => %w[past_due canceled],
        'past_due' => %w[active canceled expired],
        'canceled' => %w[expired]
      }
    end

    it 'permits only defined transitions' do
      valid_transitions.each do |from, to_states|
        to_states.each do |to|
          expect(described_class.successors[from])
            .to include(to), "expected #{from} -> #{to} to be valid"
        end
      end
    end

    it 'treats expired as a terminal state' do
      expect(described_class.successors.fetch('expired', [])).to be_empty
    end
  end
end
