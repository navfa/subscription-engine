# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Plan do
  subject(:plan) { build(:plan) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'requires a name' do
      plan.name = nil
      expect(plan).not_to be_valid
    end

    it 'requires a unique slug' do
      create(:plan, slug: 'pro')
      plan.slug = 'pro'
      expect(plan).not_to be_valid
    end

    it 'requires a currency with exactly 3 characters' do
      plan.currency = 'us'
      expect(plan).not_to be_valid
    end

    it 'rejects negative amounts' do
      plan.amount_cents = -100
      expect(plan).not_to be_valid
    end

    it 'allows zero amount for free plans' do
      plan.amount_cents = 0
      expect(plan).to be_valid
    end
  end

  describe 'enums' do
    it { expect(described_class.intervals).to eq('monthly' => 0, 'yearly' => 1) }
  end

  describe '.active' do
    it 'returns only active plans' do
      active_plan = create(:plan)
      create(:plan, :inactive)

      expect(described_class.active).to eq([active_plan])
    end
  end
end
