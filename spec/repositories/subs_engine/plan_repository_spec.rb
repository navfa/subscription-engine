# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::PlanRepository do
  subject(:repository) { described_class.new }

  describe '#find_active' do
    it 'returns active plans ordered by price ascending' do
      expensive = create(:plan, amount_cents: 4999)
      cheap = create(:plan, amount_cents: 999)
      create(:plan, :inactive)

      expect(repository.find_active).to eq([cheap, expensive])
    end
  end

  describe '#find_by_slug' do
    it 'returns Some(plan) matching the slug' do
      plan = create(:plan, slug: 'pro')
      result = repository.find_by_slug('pro')

      expect(result).to be_some
      expect(result.value!).to eq(plan)
    end

    it 'returns None when no plan matches' do
      expect(repository.find_by_slug('nonexistent')).to be_none
    end
  end

  describe '#find_by_id' do
    it 'returns Some(plan) matching the id' do
      plan = create(:plan)
      result = repository.find_by_id(plan.id)

      expect(result).to be_some
      expect(result.value!).to eq(plan)
    end

    it 'returns None when no plan matches' do
      expect(repository.find_by_id(SecureRandom.uuid)).to be_none
    end
  end
end
