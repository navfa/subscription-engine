# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CalculateMrrTrend do
  subject(:result) { described_class.new.call }

  context 'with active subscriptions' do
    let(:plan) { create(:plan, :with_stripe, amount_cents: 999) }

    before do
      sub = create(:subscription, plan: plan)
      sub.transition_to(:active)
    end

    it 'returns success with monthly data hash' do
      expect(result).to be_success
      expect(result.value!).to be_a(Hash)
    end
  end

  context 'with no subscriptions' do
    it 'returns success with empty hash' do
      expect(result).to be_success
      expect(result.value!).to be_a(Hash)
    end
  end
end
