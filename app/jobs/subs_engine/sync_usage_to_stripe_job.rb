# frozen_string_literal: true

module SubsEngine
  class SyncUsageToStripeJob < ApplicationJob
    queue_as :billing

    def perform
      SubscriptionRepository.new.find_active_metered.find_each do |subscription|
        SyncUsageToStripe.new.call(subscription)
      rescue StandardError => e
        Rails.logger.error("sync_usage failed sub=#{subscription.id} error=#{e.message}")
      end
    end
  end
end
