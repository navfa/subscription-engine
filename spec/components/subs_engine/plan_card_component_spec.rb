# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::PlanCardComponent, type: :component do
  subject(:rendered) do
    render_inline(described_class.new(plan: plan))
  end

  let(:plan) { create(:plan, name: 'Pro', amount_cents: 1999, currency: 'usd', interval: :monthly) }

  it 'renders the plan name' do
    expect(rendered.css('.subs-plan-card__name').text).to include('Pro')
  end

  it 'formats the price' do
    expect(rendered.css('.subs-plan-card__price').text).to include('19.99 USD')
  end

  it 'renders the interval' do
    expect(rendered.css('.subs-plan-card__price').text).to include('Monthly')
  end

  context 'when not subscribable' do
    it 'does not render subscribe button' do
      expect(rendered.css('.subs-btn--primary')).to be_empty
    end
  end

  context 'when subscribable' do
    subject(:rendered) do
      render_inline(described_class.new(plan: plan, subscribable: true))
    end

    it 'renders subscribe button' do
      expect(rendered.css('.subs-btn--primary').text).to include('Subscribe')
    end
  end

  context 'when plan is inactive' do
    subject(:rendered) do
      render_inline(described_class.new(plan: plan, subscribable: true))
    end

    let(:plan) { create(:plan, active: false) }

    it 'does not render subscribe button' do
      expect(rendered.css('.subs-btn--primary')).to be_empty
    end
  end
end
