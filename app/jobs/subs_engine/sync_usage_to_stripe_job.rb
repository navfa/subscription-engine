# frozen_string_literal: true

module SubsEngine
  class SyncUsageToStripeJob < ApplicationJob
    queue_as :billing

    def perform
      SubscriptionRepository.new.find_active_metered.find_each do |subscription|
        SyncUsageToStripe.new.call(subscription)
      end
    end
  end
end
