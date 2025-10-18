# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::StripeGateway do
  subject(:gateway) { described_class.new }

  describe '#create_customer' do
    let(:email) { 'test@example.com' }
    let(:stripe_customer) { Struct.new(:id).new('cus_test123') }

    context 'when stripe succeeds' do
      before { allow(Stripe::Customer).to receive(:create).and_return(stripe_customer) }

      it 'returns Success with the stripe customer' do
        result = gateway.create_customer(email: email)

        expect(result).to be_success
        expect(result.value!.id).to eq('cus_test123')
      end
    end

    context 'when stripe fails' do
      before { allow(Stripe::Customer).to receive(:create).and_raise(Stripe::StripeError, 'Connection refused') }

      it 'returns Failure[:stripe_error]' do
        result = gateway.create_customer(email: email)

        expect(result).to be_failure
        expect(result.failure).to eq([:stripe_error, 'Connection refused'])
      end
    end
  end

  describe '#create_subscription' do
    let(:stripe_sub) { Struct.new(:id, :status).new('sub_123', 'active') }

    context 'when stripe succeeds' do
      before { allow(Stripe::Subscription).to receive(:create).and_return(stripe_sub) }

      it 'returns Success with the stripe subscription' do
        result = gateway.create_subscription(customer_id: 'cus_123', price_id: 'price_456')

        expect(result).to be_success
        expect(result.value!.id).to eq('sub_123')
      end

      it 'passes the correct params to stripe' do
        gateway.create_subscription(customer_id: 'cus_123', price_id: 'price_456')

        expect(Stripe::Subscription).to have_received(:create).with(
          customer: 'cus_123',
          items: [{ price: 'price_456' }],
          metadata: {}
        )
      end
    end

    context 'when stripe fails' do
      before { allow(Stripe::Subscription).to receive(:create).and_raise(Stripe::StripeError, 'Invalid customer') }

      it 'returns Failure[:stripe_error]' do
        result = gateway.create_subscription(customer_id: 'bad', price_id: 'price_456')

        expect(result).to be_failure
        expect(result.failure).to eq([:stripe_error, 'Invalid customer'])
      end
    end
  end

  describe '#report_usage' do
    let(:usage_record) { Struct.new(:id, :quantity).new('mbur_123', 100) }

    context 'when stripe succeeds' do
      before { allow(Stripe::SubscriptionItem).to receive(:create_usage_record).and_return(usage_record) }

      it 'returns Success with the usage record' do
        result = gateway.report_usage(subscription_item_id: 'si_123', quantity: 100)

        expect(result).to be_success
        expect(result.value!.quantity).to eq(100)
      end

      it 'passes action: set for idempotent reporting' do
        gateway.report_usage(subscription_item_id: 'si_123', quantity: 100, timestamp: 1_697_500_000)

        expect(Stripe::SubscriptionItem).to have_received(:create_usage_record).with(
          'si_123',
          quantity: 100,
          timestamp: 1_697_500_000,
          action: 'set'
        )
      end
    end

    context 'when stripe fails' do
      before do
        allow(Stripe::SubscriptionItem).to receive(:create_usage_record)
          .and_raise(Stripe::StripeError, 'Invalid item')
      end

      it 'returns Failure[:stripe_error]' do
        result = gateway.report_usage(subscription_item_id: 'si_bad', quantity: 100)

        expect(result).to be_failure
        expect(result.failure).to eq([:stripe_error, 'Invalid item'])
      end
    end
  end

  describe '#cancel_subscription' do
    let(:canceled_sub) { Struct.new(:id, :status).new('sub_123', 'canceled') }

    context 'when stripe succeeds' do
      before { allow(Stripe::Subscription).to receive(:cancel).and_return(canceled_sub) }

      it 'returns Success with the canceled subscription' do
        result = gateway.cancel_subscription(stripe_subscription_id: 'sub_123')

        expect(result).to be_success
        expect(result.value!.status).to eq('canceled')
      end
    end

    context 'when stripe fails' do
      before { allow(Stripe::Subscription).to receive(:cancel).and_raise(Stripe::StripeError, 'Not found') }

      it 'returns Failure[:stripe_error]' do
        result = gateway.cancel_subscription(stripe_subscription_id: 'sub_bad')

        expect(result).to be_failure
        expect(result.failure).to eq([:stripe_error, 'Not found'])
      end
    end
  end
end
