# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Handlers::PaymentSucceeded do
  subject(:result) { described_class.new.call(payload) }

  let(:customer) { create(:customer, :with_stripe) }
  let(:subscription) { create(:subscription, :with_stripe, customer: customer) }

  before { subscription.transition_to(:active) }

  context 'with a new invoice' do
    let(:payload) do
      {
        'object' => {
          'id' => 'in_new_1',
          'subscription' => subscription.stripe_subscription_id,
          'amount_paid' => 1999,
          'currency' => 'usd',
          'period_start' => 1_696_118_400,
          'period_end' => 1_698_796_800,
          'lines' => {
            'data' => [
              { 'description' => 'Starter plan', 'amount' => 1999, 'currency' => 'usd', 'quantity' => 1 }
            ]
          }
        }
      }
    end

    it 'returns success' do
      expect(result).to be_success
    end

    it 'creates a paid invoice with correct amount' do
      result
      invoice = SubsEngine::Invoice.last

      expect(invoice.stripe_invoice_id).to eq('in_new_1')
      expect(invoice.amount_cents).to eq(1999)
      expect(invoice).to be_paid
    end

    it 'creates line items' do
      result

      expect(SubsEngine::InvoiceLineItem.count).to eq(1)
      expect(SubsEngine::InvoiceLineItem.last.description).to eq('Starter plan')
    end
  end

  context 'when invoice already exists locally' do
    let(:payload) do
      { 'object' => { 'id' => 'in_existing', 'subscription' => subscription.stripe_subscription_id } }
    end

    before { create(:invoice, customer: customer, stripe_invoice_id: 'in_existing') }

    it 'returns success without creating duplicate' do
      expect(result).to be_success
      expect(result.value!).to eq(:already_synced)
    end
  end

  context 'without subscription reference' do
    let(:payload) { { 'object' => { 'id' => 'in_no_sub' } } }

    it 'returns success with no_subscription' do
      expect(result).to be_success
      expect(result.value!).to eq(:no_subscription)
    end
  end
end
