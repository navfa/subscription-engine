# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CustomerDetailComponent, type: :component do
  subject(:rendered) { render_inline(component) }

  let(:customer) { create(:customer) }
  let(:component) do
    described_class.new(
      customer: customer,
      subscriptions: subscriptions,
      invoices: invoices
    )
  end

  context 'with subscriptions and invoices' do
    let(:subscriptions) do
      sub = create(:subscription, customer: customer)
      sub.transition_to(:active)
      [sub]
    end
    let(:invoices) { [create(:invoice, customer: customer)] }

    it 'renders customer email' do
      expect(rendered.text).to include(customer.email)
    end

    it 'renders subscription table' do
      expect(rendered.css('.subs-engine-customer-detail__subscriptions table')).to be_present
    end

    it 'renders invoice table' do
      expect(rendered.css('.subs-engine-customer-detail__invoices table')).to be_present
    end
  end

  context 'with no data' do
    let(:subscriptions) { [] }
    let(:invoices) { [] }

    it 'renders empty messages' do
      expect(rendered.text).to include('No active subscriptions')
      expect(rendered.text).to include('No invoices')
    end
  end
end
