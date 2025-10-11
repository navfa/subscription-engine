# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SubscriptionPolicy do
  subject(:policy) { described_class.new(user, subscription) }

  let(:customer) { create(:customer, external_id: '42') }
  let(:subscription) { create(:subscription, customer: customer) }

  context 'when user is the subscription owner' do
    let(:user) { double('User', id: 42, subs_engine_admin?: false) }

    it { is_expected.to be_show }
    it { is_expected.to be_cancel }
    it { is_expected.to be_update }
  end

  context 'when user is an admin but not the owner' do
    let(:user) { double('User', id: 99, subs_engine_admin?: true) }

    it { is_expected.to be_show }
    it { is_expected.not_to be_cancel }
    it { is_expected.not_to be_update }
  end

  context 'when user is neither owner nor admin' do
    let(:user) { double('User', id: 99, subs_engine_admin?: false) }

    it { is_expected.not_to be_show }
    it { is_expected.not_to be_cancel }
    it { is_expected.not_to be_update }
  end
end
