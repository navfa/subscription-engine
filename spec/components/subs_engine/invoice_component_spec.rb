# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::InvoiceComponent, type: :component do
  let(:customer) { create(:customer) }
  let(:invoice) { create(:invoice, :paid, customer: customer, amount_cents: 4999, currency: 'usd') }

  context 'with line items' do
    subject(:rendered) do
      create(:invoice_line_item, invoice: invoice, description: 'Pro plan', amount_cents: 4999)
      invoice.reload
      render_inline(described_class.new(invoice: invoice))
    end

    it 'renders the invoice status badge' do
      expect(rendered.css('.subs-badge--paid').text).to include('Paid')
    end

    it 'renders the formatted total' do
      expect(rendered.text).to include('49.99 USD')
    end

    it 'renders line items' do
      expect(rendered.text).to include('Pro plan')
      expect(rendered.css('.subs-invoice__lines')).to be_present
    end

    it 'renders the PDF download link' do
      expect(rendered.css('a.subs-btn').text).to include('Download PDF')
    end
  end

  context 'without line items' do
    subject(:rendered) { render_inline(described_class.new(invoice: invoice)) }

    it 'does not render the line items table' do
      expect(rendered.css('.subs-invoice__lines')).to be_empty
    end
  end
end
