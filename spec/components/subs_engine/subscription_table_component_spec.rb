# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SubscriptionTableComponent, type: :component do
  subject(:rendered) { render_inline(component) }

  let(:component) do
    described_class.new(
      subscriptions: subscriptions,
      current_status: nil,
      page: 1,
      total: subscriptions.size,
      per_page: 20
    )
  end

  context 'with subscriptions' do
    let(:subscriptions) do
      sub = create(:subscription)
      sub.transition_to(:active)
      [sub]
    end

    it 'renders the table with subscription data' do
      expect(rendered.css('.subs-engine-table')).to be_present
      expect(rendered.css('tbody tr').count).to eq(1)
    end

    it 'renders filter links' do
      expect(rendered.css('.subs-engine-filters')).to be_present
      expect(rendered.css('.subs-engine-filter').count).to eq(5) # All + 4 states
    end

    it 'wraps in turbo frame' do
      expect(rendered.css('turbo-frame#subscriptions_list')).to be_present
    end
  end

  context 'with no subscriptions' do
    let(:subscriptions) { [] }

    it 'renders empty message' do
      expect(rendered.css('.subs-engine-table__empty').text).to include('No subscriptions found')
    end
  end

  context 'with active filter selected' do
    let(:subscriptions) { [] }
    let(:component) do
      described_class.new(
        subscriptions: subscriptions,
        current_status: 'active',
        page: 1,
        total: 0,
        per_page: 20
      )
    end

    it 'highlights active filter' do
      expect(rendered.css('.subs-engine-filter--active').text).to include('Active')
    end
  end
end
