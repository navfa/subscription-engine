# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::InvoicePolicy do
  subject(:policy) { described_class.new(user, invoice) }

  let(:customer) { create(:customer, external_id: '42') }
  let(:invoice) { create(:invoice, customer: customer) }

  context 'when user is the invoice owner' do
    let(:user) { double('User', id: 42, subs_engine_admin?: false) }

    it { is_expected.to be_show }
  end

  context 'when user is an admin' do
    let(:user) { double('User', id: 999, subs_engine_admin?: true) }

    it { is_expected.to be_show }
  end

  context 'when user is neither owner nor admin' do
    let(:user) { double('User', id: 0, subs_engine_admin?: false) }

    it { is_expected.not_to be_show }
  end
end
