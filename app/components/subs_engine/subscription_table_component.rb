# frozen_string_literal: true

module SubsEngine
  class SubscriptionTableComponent < ViewComponent::Base
    include Turbo::FramesHelper

    STATES = [
      SubscriptionStateMachine::ACTIVE,
      SubscriptionStateMachine::TRIALING,
      SubscriptionStateMachine::PAST_DUE,
      SubscriptionStateMachine::CANCELED
    ].freeze

    attr_reader :subscriptions, :current_status, :page, :total, :per_page

    def initialize(subscriptions:, current_status: nil, page: 1, total: 0, per_page: 20)
      super
      @subscriptions = subscriptions
      @current_status = current_status
      @page = page
      @total = total
      @per_page = per_page
    end

    def filter_states
      STATES
    end

    def total_pages
      (total.to_f / per_page).ceil
    end

    def next_page?
      page < total_pages
    end

    def prev_page?
      page > 1
    end
  end
end
