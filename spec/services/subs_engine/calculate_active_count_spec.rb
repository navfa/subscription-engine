# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CalculateActiveCount do
  subject(:result) { described_class.new.call }

  context 'with active subscriptions' do
    before do
      2.times do
        sub = create(:subscription)
        sub.transition_to(:active)
      end
    end

    it 'returns success with count' do
      expect(result).to be_success
      expect(result.value!).to eq(2)
    end
  end

  context 'with no active subscriptions' do
    it 'returns success with zero' do
      expect(result).to be_success
      expect(result.value!).to eq(0)
    end
  end

  context 'when canceled subscriptions exist' do
    before do
      sub = create(:subscription)
      sub.transition_to(:active)
      sub.transition_to(:canceled)
    end

    it 'does not count them' do
      expect(result.value!).to eq(0)
    end
  end
end
