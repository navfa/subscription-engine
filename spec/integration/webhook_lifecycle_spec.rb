# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhook lifecycle', type: :request do
  let(:customer) { create(:customer, :with_stripe) }
  let(:plan) { create(:plan, :with_stripe) }
  let(:subscription) do
    create(:subscription, :with_stripe, customer: customer, plan: plan).tap do |sub|
      sub.transition_to(:active)
    end
  end
  let(:webhook_secret) { 'whsec_test123' }

  before do
    subscription
    allow(SubsEngine.configuration).to receive(:stripe_webhook_secret).and_return(webhook_secret)
  end

  def post_webhook(event_data)
    payload = event_data.to_json
    event = Stripe::Event.construct_from(event_data)
    allow(Stripe::Webhook).to receive(:construct_event).and_return(event)

    post subs_engine.webhooks_stripe_path,
         params: payload,
         headers: { 'CONTENT_TYPE' => 'application/json', 'HTTP_STRIPE_SIGNATURE' => 'sig_valid' }
  end

  it 'processes subscription.updated and transitions state' do
    post_webhook(
      id: 'evt_update_1',
      type: 'customer.subscription.updated',
      data: { object: { id: subscription.stripe_subscription_id, status: 'past_due' } }
    )

    expect(response).to have_http_status(:ok)

    perform_enqueued_jobs

    subscription.reload
    expect(subscription.current_state).to eq(SubsEngine::SubscriptionStateMachine::PAST_DUE)
    expect(SubsEngine::WebhookEvent.last).to be_processed
  end

  it 'processes subscription.deleted and cancels' do
    post_webhook(
      id: 'evt_delete_1',
      type: 'customer.subscription.deleted',
      data: { object: { id: subscription.stripe_subscription_id } }
    )

    expect(response).to have_http_status(:ok)

    perform_enqueued_jobs

    subscription.reload
    expect(subscription.current_state).to eq(SubsEngine::SubscriptionStateMachine::CANCELED)
    expect(subscription.canceled_at).to be_present
  end

  it 'deduplicates repeated events' do
    post_webhook(
      id: 'evt_dup_1',
      type: 'customer.subscription.updated',
      data: { object: { id: subscription.stripe_subscription_id, status: 'active' } }
    )
    post_webhook(
      id: 'evt_dup_1',
      type: 'customer.subscription.updated',
      data: { object: { id: subscription.stripe_subscription_id, status: 'active' } }
    )

    expect(SubsEngine::WebhookEvent.where(stripe_event_id: 'evt_dup_1').count).to eq(1)
  end

  it 'ignores unknown event types' do
    post_webhook(
      id: 'evt_unknown_1',
      type: 'charge.refunded',
      data: { object: { id: 'ch_123' } }
    )

    expect(response).to have_http_status(:ok)

    perform_enqueued_jobs

    expect(SubsEngine::WebhookEvent.last).to be_processed
  end
end
