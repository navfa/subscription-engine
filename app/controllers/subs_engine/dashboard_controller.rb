# frozen_string_literal: true

module SubsEngine
  class DashboardController < ApplicationController
    def index
      load_metrics
      load_subscriptions
    end

    private

    def load_metrics
      @mrr = CalculateMrr.new.call.value!
      @active_count = CalculateActiveCount.new.call.value!
      @churn_rate = CalculateChurnRate.new.call(
        period_start: 30.days.ago,
        period_end: Time.current
      ).value!
      @mrr_data = CalculateMrrTrend.new.call.value!
    end

    def load_subscriptions # rubocop:disable Metrics/AbcSize
      result = ListSubscriptions.new.call(
        status: params[:status],
        page: params[:page]
      ).value!

      @subscriptions = result[:records]
      @subscription_status = params[:status]
      @subscription_page = result[:meta][:page]
      @subscription_total = result[:meta][:total]
      @subscription_per_page = result[:meta][:per_page]
    end
  end
end
