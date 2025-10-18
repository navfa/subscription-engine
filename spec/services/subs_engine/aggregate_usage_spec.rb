# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::AggregateUsage do
  subject(:result) do
    described_class.new.call(
      customer: customer,
      metric_code: metric.code,
      period_start: period_start,
      period_end: period_end
    )
  end

  let(:customer) { create(:customer) }
  let(:metric) { create(:usage_metric, code: 'api_calls') }
  let(:period_start) { Time.zone.parse('2025-10-01') }
  let(:period_end) { Time.zone.parse('2025-10-31 23:59:59') }

  context 'with multiple records in period' do
    before do
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-10-05'), quantity: 100)
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-10-15'), quantity: 250)
      create(:usage_record, customer: customer, usage_metric: metric,
                            recorded_at: Time.zone.parse('2025-09-30'), quantity: 999)
    end

    it 'returns success with aggregated quantity' do
      expect(result).to be_success
      expect(result.value![:quantity]).to eq(350)
      expect(result.value![:metric]).to eq(metric)
    end
  end

  context 'with empty period' do
    it 'returns 0 quantity' do
      expect(result).to be_success
      expect(result.value![:quantity]).to eq(0)
    end
  end

  context 'with unknown metric' do
    subject(:result) do
      described_class.new.call(
        customer: customer, metric_code: 'nonexistent',
        period_start: period_start, period_end: period_end
      )
    end

    it 'returns failure' do
      expect(result).to be_failure
      expect(result.failure).to eq([:unknown_metric, 'nonexistent'])
    end
  end
end
