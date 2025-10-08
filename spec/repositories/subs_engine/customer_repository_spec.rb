# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CustomerRepository do
  subject(:repository) { described_class.new }

  describe '#find_by_external_id' do
    it 'returns Some(customer) matching the external_id' do
      customer = create(:customer, external_id: 'user_42')
      result = repository.find_by_external_id('user_42')

      expect(result).to be_some
      expect(result.value!).to eq(customer)
    end

    it 'returns None when no customer matches' do
      expect(repository.find_by_external_id('nonexistent')).to be_none
    end
  end

  describe '#find_by_stripe_id' do
    it 'returns Some(customer) matching the stripe_customer_id' do
      customer = create(:customer, :with_stripe, stripe_customer_id: 'cus_abc')
      result = repository.find_by_stripe_id('cus_abc')

      expect(result).to be_some
      expect(result.value!).to eq(customer)
    end

    it 'returns None when no customer matches' do
      expect(repository.find_by_stripe_id('cus_nonexistent')).to be_none
    end
  end

  describe '#find_by_email' do
    it 'returns Some(customer) matching the email' do
      customer = create(:customer, email: 'test@example.com')
      result = repository.find_by_email('test@example.com')

      expect(result).to be_some
      expect(result.value!).to eq(customer)
    end

    it 'returns None when no customer matches' do
      expect(repository.find_by_email('nobody@example.com')).to be_none
    end
  end
end
