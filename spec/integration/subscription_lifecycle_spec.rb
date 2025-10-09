# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subscription lifecycle', type: :request do
  let(:user) { Struct.new(:id, :subs_engine_admin?).new(42, false) }
  let(:customer) { create(:customer, :with_stripe, external_id: '42') }
  let(:plan) { create(:plan, :with_stripe) }
  let(:stripe_sub) { Struct.new(:id, :status).new('sub_lifecycle', 'active') }
  let(:canceled_sub) { Struct.new(:id, :status).new('sub_lifecycle', 'canceled') }

  before do
    sign_in_as(user)
    customer
    plan
    allow(Stripe::Subscription).to receive_messages(create: stripe_sub, cancel: canceled_sub)
  end

  it 'subscribes a customer to a plan' do
    post subs_engine.subscriptions_path(plan_id: plan.id)

    subscription = SubsEngine::Subscription.last
    expect(subscription.current_state).to eq('active')
    expect(subscription.stripe_subscription_id).to eq('sub_lifecycle')
    expect(response).to redirect_to(subs_engine.subscription_path(subscription))
  end

  it 'cancels an active subscription' do
    post subs_engine.subscriptions_path(plan_id: plan.id)
    subscription = SubsEngine::Subscription.last

    delete subs_engine.subscription_path(subscription)

    subscription.reload
    expect(subscription.current_state).to eq('canceled')
    expect(subscription.canceled_at).to be_present
    expect(response).to redirect_to(subs_engine.subscription_path(subscription))
  end

  it 'prevents double subscription' do
    post subs_engine.subscriptions_path(plan_id: plan.id)
    post subs_engine.subscriptions_path(plan_id: plan.id)

    expect(response).to redirect_to(subs_engine.plans_path)
    expect(SubsEngine::Subscription.count).to eq(1)
  end

  it 'prevents subscribing to inactive plan' do
    plan.update!(active: false)

    post subs_engine.subscriptions_path(plan_id: plan.id)

    expect(response).to redirect_to(subs_engine.plans_path)
    expect(SubsEngine::Subscription.count).to eq(0)
  end
end
