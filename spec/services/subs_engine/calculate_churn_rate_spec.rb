# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CalculateChurnRate do
  subject(:result) { described_class.new.call(period_start: period_start, period_end: period_end) }

  let(:period_start) { 30.days.ago }
  let(:period_end) { Time.current }

  context 'with churned subscriptions' do
    before do
      # 4 active at period start
      4.times do
        sub = create(:subscription, created_at: 60.days.ago)
        sub.transition_to(:active)
      end

      # 1 canceled during period
      canceled = SubsEngine::Subscription.first
      canceled.transition_to(:canceled)
      canceled.update!(canceled_at: 15.days.ago)
    end

    it 'returns the churn percentage' do
      expect(result).to be_success
      expect(result.value!).to eq(25.0)
    end
  end

  context 'with no subscriptions' do
    it 'returns zero' do
      expect(result).to be_success
      expect(result.value!).to eq(0.0)
    end
  end

  context 'with no churn' do
    before do
      sub = create(:subscription, created_at: 60.days.ago)
      sub.transition_to(:active)
    end

    it 'returns zero' do
      expect(result).to be_success
      expect(result.value!).to eq(0.0)
    end
  end
end
