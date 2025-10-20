# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::UsageMetric do
  describe 'validations' do
    subject(:usage_metric) { build(:usage_metric) }

    it { is_expected.to be_valid }

    it 'requires a name' do
      usage_metric.name = nil
      expect(usage_metric).not_to be_valid
    end

    it 'requires a code' do
      usage_metric.code = nil
      expect(usage_metric).not_to be_valid
    end

    it 'requires a unique code' do
      create(:usage_metric, code: 'api_calls')
      usage_metric.code = 'api_calls'
      expect(usage_metric).not_to be_valid
    end

    it 'requires a unit' do
      usage_metric.unit = nil
      expect(usage_metric).not_to be_valid
    end
  end

  describe '.active' do
    it 'returns only active metrics' do
      active = create(:usage_metric)
      create(:usage_metric, :inactive)

      expect(described_class.active).to eq([active])
    end
  end
end
