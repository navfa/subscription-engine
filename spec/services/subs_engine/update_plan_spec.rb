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

    it 'returns Failure[:validation_failed] with the plan' do
      expect(result).to be_failure
      expect(result.failure).to match([:validation_failed, an_instance_of(SubsEngine::Plan)])
    end

    it 'does not persist the change' do
      result
      expect(plan.reload.name).to eq('Starter')
    end
  end
end
