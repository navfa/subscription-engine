# frozen_string_literal: true

SubsEngine.configure do |config|
  config.stripe_api_key = ENV.fetch('STRIPE_API_KEY', nil)
  config.stripe_webhook_secret = ENV.fetch('STRIPE_WEBHOOK_SECRET', nil)
  config.default_currency = 'usd'
  config.trial_period_days = 14
end
