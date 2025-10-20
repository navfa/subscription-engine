# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CreateStripeCustomer do
  subject(:service) { described_class.new(gateway: gateway) }

  let(:customer) { create(:customer) }
  let(:stripe_customer) { Struct.new(:id).new('cus_new123') }
  let(:gateway) { instance_double(SubsEngine::StripeGateway) }

  before do
    allow(gateway).to receive(:create_customer).and_return(Dry::Monads::Success(stripe_customer))
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

        expect(customer.reload.stripe_customer_id).to eq('cus_new123')
      end

      it 'calls the gateway with the customer email' do
        service.call(customer)

        expect(gateway).to have_received(:create_customer)
          .with(email: customer.email, metadata: { subs_engine_id: customer.id })
      end
    end

    context 'when customer is already connected to stripe' do
      let(:customer) { create(:customer, :with_stripe) }

      it 'returns Failure[:already_connected]' do
        result = service.call(customer)

        expect(result).to be_failure
        expect(result.failure.first).to eq(:already_connected)
      end

      it 'does not call the gateway' do
        service.call(customer)

        expect(gateway).not_to have_received(:create_customer)
      end
    end

    context 'when stripe api fails' do
      before do
        allow(gateway).to receive(:create_customer)
          .and_return(Dry::Monads::Failure[:stripe_error, 'API error'])
      end

      it 'returns Failure with the stripe error' do
        result = service.call(customer)

        expect(result).to be_failure
        expect(result.failure).to eq([:stripe_error, 'API error'])
      end
    end
  end
end
