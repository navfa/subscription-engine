# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CustomerRepository do
  subject(:repository) { described_class.new }

  describe '#find_by_external_id' do
    it 'returns the customer matching the external_id' do
      customer = create(:customer, external_id: 'user_42')

      expect(repository.find_by_external_id('user_42')).to eq(customer)
    end

    it 'returns nil when no customer matches' do
      expect(repository.find_by_external_id('nonexistent')).to be_nil
    end
  end

  describe '#find_by_stripe_id' do
    it 'returns the customer matching the stripe_customer_id' do
      customer = create(:customer, :with_stripe, stripe_customer_id: 'cus_abc')

      expect(repository.find_by_stripe_id('cus_abc')).to eq(customer)
    end

    it 'returns nil when no customer matches' do
      expect(repository.find_by_stripe_id('cus_nonexistent')).to be_nil
    end
  end

  describe '#find_by_email' do
    it 'returns the customer matching the email' do
      customer = create(:customer, email: 'test@example.com')

      expect(repository.find_by_email('test@example.com')).to eq(customer)
    end

    it 'returns nil when no customer matches' do
      expect(repository.find_by_email('nobody@example.com')).to be_nil
    end
  end
end
