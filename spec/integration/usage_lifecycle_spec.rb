# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Usage metering lifecycle' do
  let(:customer) { create(:customer, :with_stripe) }
  let(:plan) { create(:plan, :with_stripe) }
  let(:subscription) do
    create(:subscription, :with_stripe, customer: customer, plan: plan,
                                        current_period_start: 1.month.ago,
                                        current_period_end: Time.current)
  end
  let(:metric) { create(:usage_metric, :with_stripe, code: 'api_calls', unit: 'calls') }
  let(:gateway) { instance_double(SubsEngine::StripeGateway) }
  let(:usage_record_struct) { Struct.new(:id).new('mbur_lifecycle') }

  before do
    subscription.transition_to(:active)
    metric
    allow(gateway).to receive(:report_usage).and_return(Dry::Monads::Success(usage_record_struct))
  end

  it 'records usage, syncs to stripe, and creates invoice with usage line items' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    # Record usage events throughout the billing period
    SubsEngine::RecordUsage.new.call(
      customer: customer, metric_code: 'api_calls', quantity: 150, recorded_at: 20.days.ago
    )
    SubsEngine::RecordUsage.new.call(
      customer: customer, metric_code: 'api_calls', quantity: 350, recorded_at: 10.days.ago
    )
    expect(SubsEngine::UsageRecord.count).to eq(2)

    # Aggregate usage for the period
    aggregate = SubsEngine::AggregateUsage.new.call(
      customer: customer, metric_code: 'api_calls',
      period_start: subscription.current_period_start,
      period_end: subscription.current_period_end
    )
    expect(aggregate.value![:quantity]).to eq(500)

    # Sync usage to stripe
    sync_result = SubsEngine::SyncUsageToStripe.new(gateway: gateway).call(subscription)
    expect(sync_result).to be_success
    expect(sync_result.value!).to include(hash_including(metric: 'api_calls', quantity: 500))

    # Simulate Stripe invoice with metered line item (via payment_succeeded webhook)
    payment_payload = {
      'object' => {
        'id' => 'in_usage_1',
        'subscription' => subscription.stripe_subscription_id,
        'amount_paid' => 2500,
        'currency' => 'usd',
        'period_start' => subscription.current_period_start.to_i,
        'period_end' => subscription.current_period_end.to_i,
        'lines' => {
          'data' => [
            {
              'description' => 'API Calls (500 calls)',
              'amount' => 2500,
              'currency' => 'usd',
              'quantity' => 500,
              'price' => { 'recurring' => { 'usage_type' => 'metered' } }
            }
          ]
        }
      }
    }
    invoice_result = SubsEngine::Handlers::PaymentSucceeded.new.call(payment_payload)
    expect(invoice_result).to be_success

    # Verify invoice has usage line item
    invoice = SubsEngine::Invoice.last
    expect(invoice.amount_cents).to eq(2500)
    expect(invoice.line_items.count).to eq(1)
    expect(invoice.line_items.first).to be_usage
    expect(invoice.line_items.first.quantity).to eq(500)
  end
end
