# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::GenerateInvoicePdf do
  subject(:result) { described_class.new.call(invoice) }

  let(:customer) { create(:customer) }
  let(:invoice) { create(:invoice, :paid, customer: customer) }

  before do
    create(:invoice_line_item, invoice: invoice, description: 'Pro plan', amount_cents: 2999)
  end

  it 'returns success with PDF binary' do
    expect(result).to be_success
    expect(result.value!).to start_with('%PDF')
  end

  it 'generates a non-empty PDF' do
    expect(result.value!.length).to be > 100
  end
end
