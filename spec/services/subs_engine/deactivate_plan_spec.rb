# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::DeactivatePlan do
  subject(:result) { described_class.new.call(plan) }

  context 'when plan is active' do
    let(:plan) { create(:plan, active: true) }

    it 'returns Success with the deactivated plan' do
      expect(result).to be_success
      expect(result.value!.active).to be(false)
    end

    it 'persists the deactivation' do
      result
      expect(plan.reload.active).to be(false)
    end
  end

  context 'when plan is already inactive' do
    let(:plan) { create(:plan, :inactive) }

    it 'returns Failure(:already_inactive)' do
      expect(result).to be_failure
      expect(result.failure).to eq(:already_inactive)
    end
  end
end
