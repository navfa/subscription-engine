# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CreatePlan do
  subject(:result) { described_class.new.call(params) }

  context 'with valid params' do
    let(:params) { { name: 'Pro', slug: 'pro', interval: 'monthly', amount_cents: 2999, currency: 'usd' } }

    it 'returns Success with the plan' do
      expect(result).to be_success
      expect(result.value!).to be_a(SubsEngine::Plan)
      expect(result.value!.name).to eq('Pro')
    end

    it 'persists the plan' do
      expect { result }.to change(SubsEngine::Plan, :count).by(1)
    end
  end

  context 'with invalid params' do
    let(:params) { { name: '', slug: '' } }

    it 'returns Failure with the plan containing errors' do
      expect(result).to be_failure
      expect(result.failure.errors).not_to be_empty
    end

    it 'does not persist' do
      expect { result }.not_to change(SubsEngine::Plan, :count)
    end
  end
end
