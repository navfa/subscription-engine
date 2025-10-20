# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::ChangePlan do
  subject(:result) { described_class.new(gateway: gateway).call(subscription: subscription, new_plan: new_plan) }

  let(:customer) { create(:customer, :with_stripe) }
  let(:current_plan) { create(:plan, :with_stripe, name: 'Starter') }
  let(:new_plan) { create(:plan, :with_stripe, name: 'Pro') }
  let(:subscription) { create(:subscription, :with_stripe, customer: customer, plan: current_plan) }
  let(:gateway) { instance_double(SubsEngine::StripeGateway) }
  let(:updated_sub) { Struct.new(:id).new(subscription.stripe_subscription_id) }

  before do
    subscription.transition_to(:active)
    allow(gateway).to receive(:update_subscription).and_return(Dry::Monads::Success(updated_sub))
  end

  context 'with valid upgrade' do
    it 'returns success and updates plan' do
      expect(result).to be_success
      expect(subscription.reload.plan).to eq(new_plan)
    end

    it 'calls stripe gateway' do
      result

      expect(gateway).to have_received(:update_subscription).with(
        stripe_subscription_id: subscription.stripe_subscription_id,
        new_price_id: new_plan.stripe_price_id
      )
    end
  end

  context 'when changing to same plan' do
    let(:new_plan) { current_plan }

    it 'returns failure' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:same_plan)
    end
  end

  context 'when new plan is inactive' do
    let(:new_plan) { create(:plan, :with_stripe, :inactive) }

    it 'returns failure' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:plan_inactive)
    end
  end

  context 'when subscription is not active' do
    before do
      subscription.transition_to(:canceled)
    end

    it 'returns failure' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:subscription_not_active)
    end
  end

  context 'when stripe fails' do
    before do
      allow(gateway).to receive(:update_subscription)
        .and_return(Dry::Monads::Failure[:stripe_error, 'card declined'])
    end

    it 'returns failure' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:stripe_error)
    end
  end
end
