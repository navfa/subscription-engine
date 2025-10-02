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
    it 'returns the plan matching the slug' do
      plan = create(:plan, slug: 'pro')

      expect(repository.find_by_slug('pro')).to eq(plan)
    end

    it 'returns nil when no plan matches' do
      expect(repository.find_by_slug('nonexistent')).to be_nil
    end
  end

  describe '#find_by_id' do
    it 'returns the plan matching the id' do
      plan = create(:plan)

      expect(repository.find_by_id(plan.id)).to eq(plan)
    end

    it 'returns nil when no plan matches' do
      expect(repository.find_by_id(SecureRandom.uuid)).to be_nil
    end
  end
end
