# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CreateStripeCustomer do
  subject(:service) { described_class.new }

  let(:customer) { create(:customer) }
  let(:stripe_customer) { Struct.new(:id).new('cus_new123') }

  before do
    allow(Stripe::Customer).to receive(:create).and_return(stripe_customer)
  end

  describe '#call' do
    context 'when customer is not connected to stripe' do
      it 'returns Success with the updated customer' do
        result = service.call(customer)

        expect(result).to be_success
        expect(result.value!.stripe_customer_id).to eq('cus_new123')
      end

      it 'persists the stripe_customer_id' do
        service.call(customer)
        customer.reload

        expect(customer.stripe_customer_id).to eq('cus_new123')
      end

      it 'calls stripe with the customer email' do
        service.call(customer)

        expect(Stripe::Customer).to have_received(:create)
          .with(email: customer.email, metadata: { subs_engine_id: customer.id })
      end
    end

    context 'when customer is already connected to stripe' do
      let(:customer) { create(:customer, :with_stripe) }

      it 'returns Failure(:already_connected)' do
        result = service.call(customer)

        expect(result).to be_failure
        expect(result.failure).to eq(:already_connected)
      end

      it 'does not call stripe' do
        service.call(customer)

        expect(Stripe::Customer).not_to have_received(:create)
      end
    end

    context 'when stripe api fails' do
      before do
        allow(Stripe::Customer).to receive(:create)
          .and_raise(Stripe::StripeError, 'API error')
      end

      it 'returns Failure with the stripe error' do
        result = service.call(customer)

        expect(result).to be_failure
        expect(result.failure).to eq(stripe_error: 'API error')
      end
    end
  end
end
