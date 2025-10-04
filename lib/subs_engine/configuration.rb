# frozen_string_literal: true

module SubsEngine
  class Configuration
    attr_accessor :stripe_api_key, :stripe_webhook_secret, :default_currency,
                  :trial_period_days, :current_user_method

    def initialize
      @stripe_api_key = nil
      @stripe_webhook_secret = nil
      @default_currency = 'usd'
      @trial_period_days = 14
      @current_user_method = :current_user
    end
  end
end
