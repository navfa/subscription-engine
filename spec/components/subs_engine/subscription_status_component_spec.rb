# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SubscriptionStatusComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(subscription: subscription))
  end

  let(:customer) { create(:customer) }
  let(:plan) { create(:plan) }
  let(:subscription) { create(:subscription, customer: customer, plan: plan) }

  context 'when trialing' do
    it 'renders trialing badge' do
      expect(rendered.css('.subs-badge--trialing').text).to include('Trialing')
    end

    it 'renders cancel button' do
      expect(rendered.css('.subs-btn--danger').text).to include('Cancel')
    end
  end

  context 'when active' do
    before { subscription.transition_to(:active) }

    it 'renders active badge' do
      expect(rendered.css('.subs-badge--active').text).to include('Active')
    end

    it 'renders cancel button' do
      expect(rendered.css('.subs-btn--danger').text).to include('Cancel')
    end
  end

  context 'when canceled' do
    before do
      subscription.transition_to(:active)
      subscription.transition_to(:canceled)
    end

    it 'renders canceled badge' do
      expect(rendered.css('.subs-badge--canceled').text).to include('Canceled')
    end

    it 'does not render cancel button' do
      expect(rendered.css('.subs-btn--danger')).to be_empty
    end
  end

  context 'with period dates' do
    let(:subscription) do
      create(:subscription, customer: customer, plan: plan,
                            current_period_start: Date.new(2025, 10, 1),
                            current_period_end: Date.new(2025, 11, 1))
    end

    it 'renders the billing period' do
      expect(rendered.css('.subs-status__period').text).to include('2025-10-01')
      expect(rendered.css('.subs-status__period').text).to include('2025-11-01')
    end
  end
end
