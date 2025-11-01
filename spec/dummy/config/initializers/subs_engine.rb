# frozen_string_literal: true

SubsEngine.configure do |config|
  config.stripe_api_key        = ENV.fetch('STRIPE_API_KEY', 'sk_test_demo')
  config.stripe_webhook_secret = ENV.fetch('STRIPE_WEBHOOK_SECRET', 'whsec_demo')
  config.default_currency      = ENV.fetch('GLOBAL_CURRENCY', 'usd')
  config.trial_period_days     = ENV.fetch('TRIAL_PERIOD_DAYS', 14).to_i
  config.gateway               = :fake
end

# Provide a demo admin user to the engine controllers
module DemoAuthentication
  DemoAdmin = Struct.new(:id, :subs_engine_admin?, keyword_init: true)

  def current_user
    @current_user ||= DemoAdmin.new(id: 1, subs_engine_admin?: true)
  end
end

Rails.application.config.to_prepare do
  SubsEngine::ApplicationController.include(DemoAuthentication)
end
