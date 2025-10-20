# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Handlers::SubscriptionUpdated do
  subject(:result) { described_class.new.call(payload) }

  let(:customer) { create(:customer, :with_stripe) }
  let(:subscription) { create(:subscription, :with_stripe, customer: customer) }

  before { subscription.transition_to(:active) }

  context 'when state changes to past_due' do
    let(:payload) do
      { 'object' => { 'id' => subscription.stripe_subscription_id, 'status' => 'past_due' } }
    end

    it 'transitions subscription to past_due' do
      expect(result).to be_success
      expect(subscription.current_state).to eq(SubsEngine::SubscriptionStateMachine::PAST_DUE)
    end
  end

  context 'when period dates are updated' do
    let(:payload) do
      {
        'object' => {
          'id' => subscription.stripe_subscription_id,
          'status' => 'active',
          'current_period_start' => 1_696_118_400,
          'current_period_end' => 1_698_796_800
        }
      }
    end

    it 'syncs the period dates' do
      result
      subscription.reload

      expect(subscription.current_period_start).to be_present
      expect(subscription.current_period_end).to be_present
    end
  end

  context 'when subscription is not found' do
    let(:payload) do
      { 'object' => { 'id' => 'sub_unknown', 'status' => 'active' } }
    end

    it 'returns failure' do
      expect(result).to be_failure
    end
  end
end
