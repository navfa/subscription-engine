# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::RecordWebhookEvent do
  subject(:service) { described_class.new }

  let(:stripe_event) do
    Stripe::Event.construct_from(
      id: 'evt_test1',
      type: 'customer.subscription.updated',
      data: { object: { id: 'sub_123' } }
    )
  end

  describe '#call' do
    it 'returns Success with the persisted event' do
      result = service.call(stripe_event)

      expect(result).to be_success
      expect(result.value!).to be_persisted
      expect(result.value!.stripe_event_id).to eq('evt_test1')
    end

    context 'when the event is a duplicate' do
      before { create(:webhook_event, stripe_event_id: 'evt_test1') }

      it 'returns Failure(:duplicate)' do
        result = service.call(stripe_event)

        expect(result).to be_failure
        expect(result.failure).to eq(:duplicate)
      end
    end
  end
end
