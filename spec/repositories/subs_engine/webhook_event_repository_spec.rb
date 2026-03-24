# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::WebhookEventRepository do
  subject(:repository) { described_class.new }

  describe '#find_by_id' do
    it 'returns Some(event) matching the id' do
      event = create(:webhook_event)
      result = repository.find_by_id(event.id)

      expect(result).to be_some
      expect(result.value!).to eq(event)
    end

    it 'returns None when no event matches' do
      expect(repository.find_by_id(0)).to be_none
    end
  end

  describe '#find_by_stripe_event_id' do
    it 'returns Some(event) matching the stripe_event_id' do
      event = create(:webhook_event, stripe_event_id: 'evt_abc')
      result = repository.find_by_stripe_event_id('evt_abc')

      expect(result).to be_some
      expect(result.value!).to eq(event)
    end

    it 'returns None when no event matches' do
      expect(repository.find_by_stripe_event_id('evt_nonexistent')).to be_none
    end
  end
end
