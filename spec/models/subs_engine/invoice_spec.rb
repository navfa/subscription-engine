# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Invoice do
  describe 'associations' do
    let(:invoice) { create(:invoice) }

    it 'belongs to customer' do
      expect(invoice.customer).to be_a(SubsEngine::Customer)
    end

    it 'has many line items' do
      create(:invoice_line_item, invoice: invoice)

      expect(invoice.line_items.count).to eq(1)
    end
  end

  describe 'validations' do
    it 'requires amount_cents' do
      invoice = build(:invoice, amount_cents: nil)

      expect(invoice).not_to be_valid
    end

    it 'requires currency with 3 characters' do
      invoice = build(:invoice, currency: 'us')

      expect(invoice).not_to be_valid
    end
  end

  describe 'scopes' do
    it '.recent returns invoices in descending order' do
      old = create(:invoice, created_at: 2.days.ago)
      recent = create(:invoice, created_at: 1.hour.ago)

      expect(described_class.recent(2)).to eq([recent, old])
    end
  end
end
