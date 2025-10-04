# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::StripeGateway do
  subject(:gateway) { described_class.new }

  describe '#create_customer' do
    let(:email) { 'test@example.com' }
    let(:stripe_customer) { Struct.new(:id).new('cus_test123') }

    context 'when stripe succeeds' do
      before do
        allow(Stripe::Customer).to receive(:create).and_return(stripe_customer)
      end

      it 'returns Success with the stripe customer' do
        result = gateway.create_customer(email: email)

        expect(result).to be_success
        expect(result.value!.id).to eq('cus_test123')
      end
    end

    context 'when stripe fails' do
      before do
        allow(Stripe::Customer).to receive(:create)
          .and_raise(Stripe::StripeError, 'Connection refused')
      end

      it 'returns Failure with the error message' do
        result = gateway.create_customer(email: email)

        expect(result).to be_failure
        expect(result.failure).to eq(stripe_error: 'Connection refused')
      end
    end
  end
end
