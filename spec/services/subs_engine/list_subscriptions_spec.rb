# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::ListSubscriptions do
  subject(:result) { described_class.new.call(**params) }

  let(:params) { {} }

  context 'with active and canceled subscriptions' do
    before do
      active = create(:subscription)
      active.transition_to(:active)

      canceled = create(:subscription)
      canceled.transition_to(:active)
      canceled.transition_to(:canceled)
    end

    it 'returns all subscriptions by default' do
      expect(result).to be_success
      expect(result.value![:records].count).to eq(2)
      expect(result.value![:meta][:total]).to eq(2)
    end

    context 'when filtering by active status' do
      let(:params) { { status: 'active' } }

      it 'returns only active subscriptions' do
        expect(result.value![:records].count).to eq(1)
        expect(result.value![:meta][:total]).to eq(1)
      end
    end

    context 'when filtering by canceled status' do
      let(:params) { { status: 'canceled' } }

      it 'returns only canceled subscriptions' do
        expect(result.value![:records].count).to eq(1)
        expect(result.value![:meta][:total]).to eq(1)
      end
    end
  end

  context 'with pagination' do
    before do
      3.times do
        sub = create(:subscription)
        sub.transition_to(:active)
      end
    end

    it 'returns page info' do
      expect(result.value![:meta][:page]).to eq(1)
      expect(result.value![:meta][:per_page]).to eq(20)
    end
  end

  context 'with no subscriptions' do
    it 'returns empty result' do
      expect(result).to be_success
      expect(result.value![:records]).to be_empty
      expect(result.value![:meta][:total]).to eq(0)
    end
  end
end
