# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::PlanPolicy do
  subject(:policy) { described_class.new(user, plan) }

  let(:plan) { build_stubbed(:plan) }

  context 'when user is an admin' do
    let(:user) { double('User', subs_engine_admin?: true) }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_deactivate }
  end

  context 'when user is not an admin' do
    let(:user) { double('User', subs_engine_admin?: false) }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_deactivate }
  end

  describe 'Scope' do
    let(:user) { double('User') }
    let!(:active_plan) { create(:plan, active: true) }
    let!(:inactive_plan) { create(:plan, :inactive) }

    it 'returns only active plans' do
      scope = described_class::Scope.new(user, SubsEngine::Plan).resolve

      expect(scope).to include(active_plan)
      expect(scope).not_to include(inactive_plan)
    end
  end
end
