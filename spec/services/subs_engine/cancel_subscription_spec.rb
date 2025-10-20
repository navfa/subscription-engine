# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CancelSubscription do
  subject(:result) { described_class.new(gateway: gateway).call(subscription) }

  let(:gateway) { instance_double(SubsEngine::StripeGateway) }
  let(:canceled_sub) { Struct.new(:id, :status).new('sub_test1', 'canceled') }

  before do
    allow(gateway).to receive(:cancel_subscription).and_return(Dry::Monads::Success(canceled_sub))
  end

  context 'when subscription is active' do
    let(:subscription) { create(:subscription, :with_stripe) }

    before { subscription.transition_to(:active) }

    it 'returns Success with the canceled subscription' do
      expect(result).to be_success
      expect(result.value!.current_state).to eq(SubsEngine::SubscriptionStateMachine::CANCELED)
    end

    it 'sets canceled_at' do
      result
      expect(subscription.reload.canceled_at).to be_present
    end

    it 'calls the gateway to cancel on stripe' do
      result

      expect(gateway).to have_received(:cancel_subscription)
        .with(stripe_subscription_id: subscription.stripe_subscription_id)
    end
  end

  context 'when subscription is trialing' do
    let(:subscription) { create(:subscription, :with_stripe) }

    it 'cancels from trialing state' do
      expect(result).to be_success
      expect(result.value!.current_state).to eq(SubsEngine::SubscriptionStateMachine::CANCELED)
    end
  end

  context 'when subscription is already canceled' do
    let(:subscription) { create(:subscription, :with_stripe) }

    before do
      subscription.transition_to(:active)
      subscription.transition_to(:canceled)
    end

    it 'returns Failure[:already_canceled]' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:already_canceled)
    end
  end

  context 'when stripe fails' do
    let(:subscription) { create(:subscription, :with_stripe) }

    before do
      subscription.transition_to(:active)
      allow(gateway).to receive(:cancel_subscription)
        .and_return(Dry::Monads::Failure[:stripe_error, 'Network error'])
    end

    it 'returns Failure[:stripe_error]' do
      expect(result).to be_failure
      expect(result.failure).to eq([:stripe_error, 'Network error'])
    end

    it 'does not transition the subscription' do
      result
      expect(subscription.current_state).to eq(SubsEngine::SubscriptionStateMachine::ACTIVE)
    end
  end

  context 'when subscription has no stripe id' do
    let(:subscription) { create(:subscription) }

    before { subscription.transition_to(:active) }

    it 'skips stripe cancellation and cancels locally' do
      expect(result).to be_success
      expect(gateway).not_to have_received(:cancel_subscription)
    end
  end
end
