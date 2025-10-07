# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::UpdatePlan do
  subject(:result) { described_class.new.call(plan, params) }

  let(:plan) { create(:plan, name: 'Starter') }

  context 'with valid params' do
    let(:params) { { name: 'Pro' } }

    it 'returns Success with the updated plan' do
      expect(result).to be_success
      expect(result.value!.name).to eq('Pro')
    end

    it 'persists the change' do
      result
      expect(plan.reload.name).to eq('Pro')
    end
  end

  context 'with invalid params' do
    let(:params) { { name: '' } }

    it 'returns Failure with the plan containing errors' do
      expect(result).to be_failure
      expect(result.failure.errors).not_to be_empty
    end

    it 'does not persist the change' do
      result
      expect(plan.reload.name).to eq('Starter')
    end
  end
end
