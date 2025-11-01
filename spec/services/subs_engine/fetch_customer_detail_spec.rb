# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::FetchCustomerDetail do
  subject(:result) { described_class.new.call(customer_id: customer_id) }

  context 'with existing customer' do
    let(:customer) { create(:customer) }
    let(:customer_id) { customer.id }

    before do
      sub = create(:subscription, customer: customer)
      sub.transition_to(:active)
      create(:invoice, customer: customer, subscription: sub)
    end

    it 'returns success with customer detail' do # rubocop:disable RSpec/MultipleExpectations
      expect(result).to be_success
      expect(result.value![:customer]).to eq(customer)
      expect(result.value![:subscriptions].count).to eq(1)
      expect(result.value![:invoices].count).to eq(1)
    end
  end

  context 'with unknown customer' do
    let(:customer_id) { 0 }

    it 'returns failure' do
      expect(result).to be_failure
      expect(result.failure).to eq(:customer_not_found)
    end
  end
end
