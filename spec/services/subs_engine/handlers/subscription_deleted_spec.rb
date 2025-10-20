# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Handlers::SubscriptionDeleted do
  subject(:result) { described_class.new.call(payload) }

  let(:customer) { create(:customer, :with_stripe) }
  let(:subscription) { create(:subscription, :with_stripe, customer: customer) }
  let(:payload) do
    { 'object' => { 'id' => subscription.stripe_subscription_id } }
  end

  before { subscription.transition_to(:active) }

  it 'transitions to canceled' do
    expect(result).to be_success
    expect(subscription.current_state).to eq(SubsEngine::SubscriptionStateMachine::CANCELED)
  end

  it 'sets canceled_at' do
    result
    expect(subscription.reload.canceled_at).to be_present
  end

  context 'when already canceled' do
    before do
      subscription.transition_to(:canceled)
    end

    it 'returns success without error' do
      expect(result).to be_success
    end
  end
end
