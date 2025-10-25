# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::MrrChartComponent, type: :component do
  subject(:rendered) { render_inline(component) }

  let(:component) { described_class.new(data: data) }
  let(:data) { { 'Jan 2025' => 4999, 'Feb 2025' => 9998 } }

  it 'renders chart container' do
    expect(rendered.css('.subs-engine-chart')).to be_present
  end

  it 'renders title' do
    expect(rendered.css('.subs-engine-chart__title').text).to include('MRR Trend')
  end

  describe '#chart_data' do
    it 'converts cents to dollars' do
      expect(component.chart_data).to eq({ 'Jan 2025' => 49.99, 'Feb 2025' => 99.98 })
    end
  end
end
