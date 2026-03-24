# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::ProcessWebhookEventJob do
  let(:event) { create(:webhook_event) }
  let(:dispatcher) { instance_double(SubsEngine::WebhookEventDispatcher) }

  before do
    allow(SubsEngine::WebhookEventDispatcher).to receive(:new).and_return(dispatcher)
  end

  describe '#perform' do
    context 'when handler succeeds' do
      before { allow(dispatcher).to receive(:call).and_return(Dry::Monads::Success(:ok)) }

      it 'marks the event as processed' do
        described_class.perform_now(event.id)

        expect(event.reload).to be_processed
      end
    end

    context 'when handler fails' do
      before { allow(dispatcher).to receive(:call).and_return(Dry::Monads::Failure[:handler_error, 'boom']) }

      it 'marks the event as failed with error message' do
        described_class.perform_now(event.id)

        event.reload
        expect(event).to be_failed
        expect(event.error_message).to eq('boom')
      end
    end

    context 'when event is already processed' do
      let(:event) { create(:webhook_event, :processed) }

      before { allow(dispatcher).to receive(:call) }

      it 'skips processing' do
        described_class.perform_now(event.id)

        expect(dispatcher).not_to have_received(:call)
      end
    end

    context 'when event does not exist' do
      before { allow(dispatcher).to receive(:call) }

      it 'returns without processing' do
        described_class.perform_now(0)

        expect(dispatcher).not_to have_received(:call)
      end
    end
  end
end
