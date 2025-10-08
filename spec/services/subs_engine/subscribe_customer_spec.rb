# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SubscribeCustomer do
  subject(:result) { described_class.new.call(customer: customer, plan: plan, gateway: gateway) }

  let(:customer) { create(:customer, :with_stripe) }
  let(:plan) { create(:plan, :with_stripe) }
  let(:gateway) { instance_double(SubsEngine::StripeGateway) }
  let(:stripe_sub) { Struct.new(:id, :status).new('sub_test123', 'active') }

  before do
    allow(gateway).to receive(:create_subscription).and_return(Dry::Monads::Success(stripe_sub))
  end

  context 'when customer and plan are valid' do
    it 'returns Success with the subscription' do
      expect(result).to be_success
      expect(result.value!).to be_a(SubsEngine::Subscription)
    end

    it 'creates a subscription in active state' do
      subscription = result.value!

      expect(subscription.current_state).to eq('active')
      expect(subscription.stripe_subscription_id).to eq('sub_test123')
    end

    it 'calls the gateway with correct params' do
      result

      expect(gateway).to have_received(:create_subscription).with(
        customer_id: customer.stripe_customer_id,
        price_id: plan.stripe_price_id,
        metadata: { subs_engine_plan_id: plan.id }
      )
    end
  end

  context 'when plan is inactive' do
    let(:plan) { create(:plan, :inactive, :with_stripe) }

    it 'returns Failure[:plan_inactive]' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:plan_inactive)
    end

    it 'does not call the gateway' do
      result
      expect(gateway).not_to have_received(:create_subscription)
    end
  end

  context 'when customer already has an active subscription' do
    before do
      sub = create(:subscription, customer: customer, plan: plan)
      sub.transition_to(:active)
    end

    it 'returns Failure[:already_subscribed]' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:already_subscribed)
    end
  end

  context 'when customer has no stripe id' do
    let(:customer) { create(:customer) }
    let(:stripe_customer) { Struct.new(:id).new('cus_new456') }

    before do
      allow(gateway).to receive(:create_customer).and_return(Dry::Monads::Success(stripe_customer))
    end

    it 'creates the stripe customer first then subscribes' do
      expect(result).to be_success
      expect(customer.reload.stripe_customer_id).to eq('cus_new456')
    end
  end

  context 'when stripe fails' do
    before do
      allow(gateway).to receive(:create_subscription)
        .and_return(Dry::Monads::Failure[:stripe_error, 'Card declined'])
    end

    it 'returns Failure[:stripe_error]' do
      expect(result).to be_failure
      expect(result.failure).to eq([:stripe_error, 'Card declined'])
    end
  end
end
