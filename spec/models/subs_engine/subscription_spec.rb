# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Subscription do
  subject(:subscription) { create(:subscription) }

  describe 'associations' do
    it 'belongs to a customer' do
      expect(subscription.customer).to be_a(SubsEngine::Customer)
    end

    it 'belongs to a plan' do
      expect(subscription.plan).to be_a(SubsEngine::Plan)
    end
  end

  describe 'state machine' do
    it 'starts in trialing state' do
      expect(subscription.current_state).to eq('trialing')
    end

    it 'transitions from trialing to active' do
      expect(subscription.transition_to(:active)).to be true
      expect(subscription.current_state).to eq('active')
    end

    it 'transitions from trialing to canceled' do
      expect(subscription.transition_to(:canceled)).to be true
      expect(subscription.current_state).to eq('canceled')
    end

    it 'transitions from active to past_due' do
      subscription.transition_to(:active)
      expect(subscription.transition_to(:past_due)).to be true
    end

    it 'transitions from past_due back to active' do
      subscription.transition_to(:active)
      subscription.transition_to(:past_due)
      expect(subscription.transition_to(:active)).to be true
    end

    it 'transitions from canceled to expired' do
      subscription.transition_to(:canceled)
      expect(subscription.transition_to(:expired)).to be true
    end

    it 'rejects invalid transitions' do
      expect(subscription.can_transition_to?(:expired)).to be false
    end

    it 'records transition history' do
      subscription.transition_to(:active)

      expect(subscription.transitions.count).to eq(1)
      expect(subscription.transitions.last.to_state).to eq('active')
    end
  end
end
