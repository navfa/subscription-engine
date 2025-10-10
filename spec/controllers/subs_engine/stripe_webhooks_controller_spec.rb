# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::StripeWebhooksController, type: :controller do
  routes { SubsEngine::Engine.routes }

  let(:webhook_secret) { 'whsec_test123' }
  let(:payload) { { id: 'evt_1', type: 'customer.subscription.updated', data: { object: {} } }.to_json }

  before do
    allow(SubsEngine.configuration).to receive(:stripe_webhook_secret).and_return(webhook_secret)
  end

  describe 'POST #create' do
    context 'with valid signature' do
      let(:event) { Stripe::Event.construct_from(JSON.parse(payload)) }

      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
      end

      it 'returns ok and persists the event' do
        post :create, body: payload

        expect(response).to have_http_status(:ok)
        expect(SubsEngine::WebhookEvent.count).to eq(1)
      end

      it 'enqueues a processing job' do
        expect { post :create, body: payload }
          .to have_enqueued_job(SubsEngine::ProcessWebhookEventJob)
      end
    end

    context 'with invalid signature' do
      before do
        allow(Stripe::Webhook).to receive(:construct_event)
          .and_raise(Stripe::SignatureVerificationError.new('bad sig', 'sig'))
      end

      it 'returns bad request' do
        post :create, body: payload

        expect(response).to have_http_status(:bad_request)
      end

      it 'does not persist an event' do
        post :create, body: payload

        expect(SubsEngine::WebhookEvent.count).to eq(0)
      end
    end

    context 'with duplicate event' do
      let(:event) { Stripe::Event.construct_from(JSON.parse(payload)) }

      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
        create(:webhook_event, stripe_event_id: 'evt_1')
      end

      it 'returns ok without enqueuing' do
        expect { post :create, body: payload }
          .not_to have_enqueued_job(SubsEngine::ProcessWebhookEventJob)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
