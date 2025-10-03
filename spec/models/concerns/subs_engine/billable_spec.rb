# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Billable do
  let(:user) { DummyUser.create!(email: 'test@example.com') }

  describe '#billing_customer' do
    it 'returns nil when no customer exists' do
      expect(user.billing_customer).to be_nil
    end

    it 'returns the linked billing customer' do
      customer = create(:customer, external_id: user.id)

      expect(user.billing_customer).to eq(customer)
    end
  end

  describe '#subscribed?' do
    it 'returns false when no customer exists' do
      expect(user).not_to be_subscribed
    end

    it 'returns false when customer has no active subscription' do
      create(:customer, external_id: user.id)

      expect(user).not_to be_subscribed
    end

    it 'returns true when customer has an active subscription' do
      customer = create(:customer, external_id: user.id)
      subscription = create(:subscription, customer: customer)
      subscription.transition_to(:active)

      expect(user).to be_subscribed
    end
  end

  describe '#active_subscription' do
    it 'returns the active subscription' do
      customer = create(:customer, external_id: user.id)
      subscription = create(:subscription, customer: customer)
      subscription.transition_to(:active)

      expect(user.active_subscription).to eq(subscription)
    end

    it 'returns nil when no active subscription' do
      create(:customer, external_id: user.id)

      expect(user.active_subscription).to be_nil
    end
  end
end
