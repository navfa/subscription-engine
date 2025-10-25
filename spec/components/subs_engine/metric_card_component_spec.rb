# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::MetricCardComponent, type: :component do
  subject(:rendered) { render_inline(component) }

  let(:component) { described_class.new(label: 'MRR', value: '$49.99') }

  it 'renders label and value' do
    expect(rendered.css('.subs-engine-card__label').text).to include('MRR')
    expect(rendered.css('.subs-engine-card__value').text).to include('$49.99')
  end

  context 'with positive style' do
    let(:component) { described_class.new(label: 'MRR', value: '$100', style: :positive) }

    it 'applies positive class' do
      expect(rendered.css('.subs-engine-card__value--positive')).to be_present
    end
  end

  context 'with negative style' do
    let(:component) { described_class.new(label: 'Churn', value: '12%', style: :negative) }

    it 'applies negative class' do
      expect(rendered.css('.subs-engine-card__value--negative')).to be_present
    end
  end
end
