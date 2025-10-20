# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Handlers::PaymentFailed do
  subject(:result) { described_class.new.call(payload) }

  let(:customer) { create(:customer, :with_stripe) }
  let(:subscription) { create(:subscription, :with_stripe, customer: customer) }

  before { subscription.transition_to(:active) }

  context 'with matching subscription' do
    let(:payload) do
      { 'object' => { 'subscription' => subscription.stripe_subscription_id } }
    end

    it 'transitions to past_due' do
      expect(result).to be_success
      expect(subscription.current_state).to eq(SubsEngine::SubscriptionStateMachine::PAST_DUE)
    end
  end

  context 'when already past_due' do
    let(:payload) do
      { 'object' => { 'subscription' => subscription.stripe_subscription_id } }
    end

    before { subscription.transition_to(:past_due) }

    it 'returns success without error' do
      expect(result).to be_success
    end
  end

  context 'without subscription reference' do
    let(:payload) { { 'object' => {} } }

    it 'returns success with no_subscription' do
      expect(result).to be_success
      expect(result.value!).to eq(:no_subscription)
    end
  end
end
