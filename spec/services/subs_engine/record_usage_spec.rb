# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::RecordUsage do
  subject(:result) { described_class.new.call(customer: customer, metric_code: metric.code, quantity: quantity) }

  let(:customer) { create(:customer) }
  let(:metric) { create(:usage_metric, code: 'api_calls') }
  let(:quantity) { 10 }

  it 'returns success with usage record' do
    expect(result).to be_success
    expect(result.value!).to be_a(SubsEngine::UsageRecord)
    expect(result.value!.quantity).to eq(10)
  end

  it 'creates a persisted usage record' do
    result
    expect(SubsEngine::UsageRecord.count).to eq(1)
  end

  context 'when metric does not exist' do
    subject(:result) { described_class.new.call(customer: customer, metric_code: 'nonexistent', quantity: 5) }

    it 'returns failure with unknown_metric' do
      expect(result).to be_failure
      expect(result.failure).to eq([:unknown_metric, 'nonexistent'])
    end
  end

  context 'when metric is inactive' do
    let(:metric) { create(:usage_metric, :inactive, code: 'deprecated') }

    subject(:result) { described_class.new.call(customer: customer, metric_code: 'deprecated', quantity: 5) }

    it 'returns failure with unknown_metric' do
      expect(result).to be_failure
      expect(result.failure.first).to eq(:unknown_metric)
    end
  end

  context 'when quantity is zero' do
    let(:quantity) { 0 }

    it 'returns failure with invalid_quantity' do
      expect(result).to be_failure
      expect(result.failure).to eq([:invalid_quantity, 0])
    end
  end

  context 'when quantity is negative' do
    let(:quantity) { -5 }

    it 'returns failure with invalid_quantity' do
      expect(result).to be_failure
      expect(result.failure).to eq([:invalid_quantity, -5])
    end
  end
end
