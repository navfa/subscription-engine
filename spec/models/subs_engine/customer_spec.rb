# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Customer do
  subject(:customer) { build(:customer) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'requires an external_id' do
      customer.external_id = nil
      expect(customer).not_to be_valid
    end

    it 'requires a unique external_id' do
      create(:customer, external_id: 'user_42')
      customer.external_id = 'user_42'
      expect(customer).not_to be_valid
    end

    it 'requires a valid email' do
      customer.email = 'not-an-email'
      expect(customer).not_to be_valid
    end

    it 'enforces unique stripe_customer_id when present' do
      create(:customer, :with_stripe, stripe_customer_id: 'cus_abc')
      customer.stripe_customer_id = 'cus_abc'
      expect(customer).not_to be_valid
    end

    it 'allows nil stripe_customer_id' do
      customer.stripe_customer_id = nil
      expect(customer).to be_valid
    end
  end

  describe '#stripe_connected?' do
    it 'returns true when stripe_customer_id is present' do
      customer.stripe_customer_id = 'cus_abc'
      expect(customer).to be_stripe_connected
    end

    it 'returns false when stripe_customer_id is nil' do
      expect(customer).not_to be_stripe_connected
    end
  end

  describe '.with_stripe' do
    it 'returns only customers connected to stripe' do
      connected = create(:customer, :with_stripe)
      create(:customer)

      expect(described_class.with_stripe).to eq([connected])
    end
  end
end
