# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SubsEngine::Invoices', type: :request do
  let(:customer) { create(:customer, :with_stripe, external_id: '42') }
  let(:user) { double('User', id: 42) } # rubocop:disable RSpec/VerifiedDoubles

  before { sign_in_as(user) }

  describe 'GET /index' do
    it 'lists invoices for the current customer' do
      create(:invoice, :paid, customer: customer)

      get subs_engine.invoices_path
      expect(response).to have_http_status(:ok)
    end

    it 'returns not_found when customer does not exist' do
      sign_in_as(double('User', id: 0)) # rubocop:disable RSpec/VerifiedDoubles

      get subs_engine.invoices_path
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /show' do
    let(:invoice) { create(:invoice, :paid, customer: customer) }

    it 'shows the invoice' do
      get subs_engine.invoice_path(invoice)
      expect(response).to have_http_status(:ok)
    end

    it 'serves a PDF when requested' do
      create(:invoice_line_item, invoice: invoice)

      get subs_engine.invoice_path(invoice, format: :pdf)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/pdf')
    end

    it 'denies access to other users' do
      sign_in_as(double('User', id: 0, subs_engine_admin?: false)) # rubocop:disable RSpec/VerifiedDoubles

      get subs_engine.invoice_path(invoice)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
