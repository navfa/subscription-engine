# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::InvoiceRepository do
  subject(:repo) { described_class.new }

  let(:customer) { create(:customer) }

  describe '#find_by_id' do
    it 'returns Some for existing invoice' do
      invoice = create(:invoice, customer: customer)

      expect(repo.find_by_id(invoice.id)).to be_some
    end

    it 'returns None for missing invoice' do
      expect(repo.find_by_id(SecureRandom.uuid)).to be_none
    end
  end

  describe '#find_by_stripe_id' do
    it 'returns Some for existing stripe id' do
      create(:invoice, customer: customer, stripe_invoice_id: 'in_find')

      expect(repo.find_by_stripe_id('in_find')).to be_some
    end

    it 'returns None for unknown stripe id' do
      expect(repo.find_by_stripe_id('in_nope')).to be_none
    end
  end

  describe '#find_by_customer' do
    it 'returns invoices for the customer' do
      create(:invoice, customer: customer)
      other = create(:customer)
      create(:invoice, customer: other)

      expect(repo.find_by_customer(customer).count).to eq(1)
    end
  end

  describe '#find_by_status' do
    it 'returns invoices with matching status' do
      create(:invoice, :paid, customer: customer)
      create(:invoice, :open, customer: customer)

      expect(repo.find_by_status(:paid).count).to eq(1)
    end
  end

  describe '#find_recent' do
    it 'returns limited results in descending order' do
      3.times { create(:invoice, customer: customer) }

      expect(repo.find_recent(limit: 2).count).to eq(2)
    end
  end
end
