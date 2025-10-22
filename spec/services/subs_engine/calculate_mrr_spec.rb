# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CalculateMrr do
  subject(:result) { described_class.new.call }

  context 'with active subscriptions' do
    let(:plan_a) { create(:plan, :with_stripe, amount_cents: 999) }
    let(:plan_b) { create(:plan, :with_stripe, amount_cents: 2999) }

    before do
      sub_a = create(:subscription, plan: plan_a)
      sub_a.transition_to(:active)
      sub_b = create(:subscription, plan: plan_b)
      sub_b.transition_to(:active)
    end

    it 'returns success with total MRR in cents' do
      expect(result).to be_success
      expect(result.value!).to eq(3998)
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
      sub = create(:subscription, plan: create(:plan, :with_stripe, amount_cents: 999))
      sub.transition_to(:active)
      sub.transition_to(:canceled)
    end

    it 'does not count them' do
      expect(result.value!).to eq(0)
    end
  end
end
