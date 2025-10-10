# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::WebhookEvent do
  describe 'validations' do
    it 'requires stripe_event_id' do
      event = build(:webhook_event, stripe_event_id: nil)

      expect(event).not_to be_valid
      expect(event.errors[:stripe_event_id]).to include("can't be blank")
    end

    it 'requires unique stripe_event_id' do
      create(:webhook_event, stripe_event_id: 'evt_dup')
      duplicate = build(:webhook_event, stripe_event_id: 'evt_dup')

      expect(duplicate).not_to be_valid
    end

    it 'requires event_type' do
      event = build(:webhook_event, event_type: nil)

      expect(event).not_to be_valid
    end
  end

  describe '#mark_processed!' do
    let(:event) { create(:webhook_event) }

    it 'updates status to processed' do
      event.mark_processed!

      expect(event.reload).to be_processed
    end
  end

  describe '#mark_failed!' do
    let(:event) { create(:webhook_event) }

    it 'updates status and error message' do
      event.mark_failed!('something broke')

      event.reload
      expect(event).to be_failed
      expect(event.error_message).to eq('something broke')
    end
  end
end
