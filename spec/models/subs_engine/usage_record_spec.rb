# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::UsageRecord do
  describe 'validations' do
    subject { build(:usage_record) }

    it { is_expected.to be_valid }

    it 'requires a quantity greater than 0' do
      subject.quantity = 0
      expect(subject).not_to be_valid
    end

    it 'requires recorded_at' do
      subject.recorded_at = nil
      expect(subject).not_to be_valid
    end
  end

  describe 'immutability' do
    it 'prevents updates to persisted records' do
      record = create(:usage_record, quantity: 5)

      record.quantity = 10
      expect(record.save).to be false
      expect(record.reload.quantity).to eq(5)
    end
  end

  describe '.for_period' do
    let(:customer) { create(:customer) }
    let(:metric) { create(:usage_metric) }

    it 'returns records within the period' do
      inside = create(:usage_record, customer: customer, usage_metric: metric,
                                     recorded_at: Time.zone.parse('2025-10-15'))
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-09-01'))

      result = described_class.for_period(Time.zone.parse('2025-10-01'), Time.zone.parse('2025-10-31'))
      expect(result).to eq([inside])
    end
  end
end
