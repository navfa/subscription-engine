# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::UsageRepository do
  subject(:repo) { described_class.new }

  let(:customer) { create(:customer) }
  let(:metric) { create(:usage_metric) }
  let(:period_start) { Time.zone.parse('2025-10-01') }
  let(:period_end) { Time.zone.parse('2025-10-31 23:59:59') }

  describe '#find_by_customer_and_period' do
    it 'returns records within the period for the given metric' do
      inside = create(:usage_record, customer: customer, usage_metric: metric,
                                     recorded_at: Time.zone.parse('2025-10-15'), quantity: 5)
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-09-15'), quantity: 3)

      result = repo.find_by_customer_and_period(customer, metric, period_start, period_end)
      expect(result).to eq([inside])
    end

    it 'returns empty when no records exist' do
      result = repo.find_by_customer_and_period(customer, metric, period_start, period_end)
      expect(result).to be_empty
    end
  end

  describe '#sum_by_metric' do
    it 'sums quantities for the period' do
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-10-10'), quantity: 5)
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-10-20'), quantity: 3)
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-09-15'), quantity: 100)

      result = repo.sum_by_metric(customer, metric, period_start, period_end)
      expect(result).to eq(8)
    end

    it 'returns 0 for empty period' do
      result = repo.sum_by_metric(customer, metric, period_start, period_end)
      expect(result).to eq(0)
    end
  end

  describe '#find_by_customer' do
    it 'returns recent records for the customer' do
      create(:usage_record, customer: customer, usage_metric: metric, quantity: 1)
      create(:usage_record, customer: customer, usage_metric: metric, quantity: 2)

      result = repo.find_by_customer(customer)
      expect(result.size).to eq(2)
    end
  end
end
