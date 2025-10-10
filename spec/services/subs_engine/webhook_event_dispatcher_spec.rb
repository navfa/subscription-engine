# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::WebhookEventDispatcher do
  subject(:result) { described_class.new.call(event) }

  describe '#call' do
    context 'with a known event type' do
      let(:event) { create(:webhook_event, event_type: 'customer.subscription.updated') }
      let(:handler) { instance_double(SubsEngine::Handlers::SubscriptionUpdated) }

      before do
        allow(SubsEngine::Handlers::SubscriptionUpdated).to receive(:new).and_return(handler)
        allow(handler).to receive(:call).and_return(Dry::Monads::Success(:ok))
      end

      it 'dispatches to the correct handler' do
        expect(result).to be_success
        expect(handler).to have_received(:call).with(event.payload)
      end
    end

    context 'with an unknown event type' do
      let(:event) { create(:webhook_event, event_type: 'charge.refunded') }

      it 'returns success with ignored' do
        expect(result).to be_success
        expect(result.value!).to eq(:ignored)
      end
    end
  end
end
