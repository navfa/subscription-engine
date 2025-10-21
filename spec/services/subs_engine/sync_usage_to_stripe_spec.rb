# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SyncUsageToStripe do
  subject(:result) { described_class.new(gateway: gateway).call(subscription) }

  let(:customer) { create(:customer, :with_stripe) }
  let(:subscription) do
    create(:subscription, :with_stripe, customer: customer,
                                        current_period_start: 1.month.ago,
                                        current_period_end: Time.current)
  end
  let(:metric) { create(:usage_metric) }
  let(:gateway) { instance_double(SubsEngine::StripeGateway) }
  let(:usage_record_struct) { Struct.new(:id).new('mbur_123') }

  before do
    subscription.transition_to(:active)
    allow(gateway).to receive(:report_usage).and_return(Dry::Monads::Success(usage_record_struct))
  end

  context 'when customer has usage in the current period' do
    before do
      create(:usage_record, customer: customer, usage_metric: metric,
                            quantity: 50, recorded_at: 15.days.ago)
      create(:usage_record, customer: customer, usage_metric: metric,
                            quantity: 30, recorded_at: 10.days.ago)
    end

    it 'returns success with synced metrics' do
      expect(result).to be_success
      expect(result.value!).to include(hash_including(metric: metric.code, quantity: 80))
    end

    it 'reports aggregated usage to stripe' do
      result

      expect(gateway).to have_received(:report_usage).with(
        subscription_item_id: subscription.stripe_subscription_item_id,
        quantity: 80,
        timestamp: subscription.current_period_start.to_i
      )
    end
  end

  context 'when customer has no usage' do
    it 'returns success with empty results' do
      expect(result).to be_success
      expect(result.value!).to be_empty
    end

    it 'does not call stripe' do
      result
      expect(gateway).not_to have_received(:report_usage)
    end
  end

  context 'when stripe fails' do
    before do
      create(:usage_record, customer: customer, usage_metric: metric,
                            quantity: 10, recorded_at: 15.days.ago)
      allow(gateway).to receive(:report_usage)
        .and_return(Dry::Monads::Failure[:stripe_error, 'Invalid item'])
    end

    it 'returns success with empty synced list' do
      expect(result).to be_success
      expect(result.value!).to be_empty
    end
  end
end
