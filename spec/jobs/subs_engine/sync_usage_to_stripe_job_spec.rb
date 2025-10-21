# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SyncUsageToStripeJob do
  let(:customer) { create(:customer, :with_stripe) }
  let(:subscription) do
    create(:subscription, :with_stripe, customer: customer,
                                        current_period_start: 1.month.ago,
                                        current_period_end: Time.current)
  end

  before { subscription.transition_to(:active) }

  it 'enqueues on the billing queue' do
    expect(described_class.new.queue_name).to eq('billing')
  end

  it 'processes active metered subscriptions' do
    sync_service = instance_double(SubsEngine::SyncUsageToStripe)
    allow(SubsEngine::SyncUsageToStripe).to receive(:new).and_return(sync_service)
    allow(sync_service).to receive(:call).and_return(Dry::Monads::Success([]))

    described_class.perform_now

    expect(sync_service).to have_received(:call).with(subscription)
  end

  it 'skips subscriptions without stripe_subscription_item_id' do
    create(:subscription, customer: customer, current_period_start: 1.month.ago,
                          current_period_end: Time.current).tap { |s| s.transition_to(:active) }

    sync_service = instance_double(SubsEngine::SyncUsageToStripe)
    allow(SubsEngine::SyncUsageToStripe).to receive(:new).and_return(sync_service)
    allow(sync_service).to receive(:call).and_return(Dry::Monads::Success([]))

    described_class.perform_now

    expect(sync_service).to have_received(:call).once
  end
end
