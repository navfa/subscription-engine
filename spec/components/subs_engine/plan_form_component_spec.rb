# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::PlanFormComponent, type: :component do
  context 'with a new plan' do
    subject(:rendered) do
      render_inline(described_class.new(plan: plan))
    end

    let(:plan) { SubsEngine::Plan.new }

    it 'renders a create form' do
      expect(rendered.css("input[type='submit']").first['value']).to eq('Create Plan')
    end

    it 'renders text fields' do
      expect(rendered.css("input[name='plan[name]']")).to be_present
      expect(rendered.css("input[name='plan[slug]']")).to be_present
      expect(rendered.css("input[name='plan[currency]']")).to be_present
    end

    it 'renders numeric and select fields' do
      expect(rendered.css("select[name='plan[interval]']")).to be_present
      expect(rendered.css("input[name='plan[amount_cents]']")).to be_present
    end

    it 'renders interval options' do
      options = rendered.css("select[name='plan[interval]'] option").map(&:text)
      expect(options).to include('monthly', 'yearly')
    end
  end

  context 'with an existing plan' do
    subject(:rendered) do
      render_inline(described_class.new(plan: plan))
    end

    let(:plan) { create(:plan, name: 'Starter') }

    it 'renders an update form' do
      expect(rendered.css("input[type='submit']").first['value']).to eq('Update Plan')
    end

    it 'pre-fills the name field' do
      expect(rendered.css("input[name='plan[name]']").first['value']).to eq('Starter')
    end
  end

  context 'with validation errors' do
    subject(:rendered) do
      render_inline(described_class.new(plan: plan))
    end

    let(:plan) do
      plan = SubsEngine::Plan.new
      plan.validate
      plan
    end

    it 'renders error messages' do
      expect(rendered.css('.subs-form-errors li').size).to be > 0
    end
  end
end
