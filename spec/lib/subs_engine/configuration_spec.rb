# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::Configuration do
  subject(:config) { described_class.new }

  it 'has sensible defaults' do
    expect(config.default_currency).to eq('usd')
    expect(config.trial_period_days).to eq(14)
    expect(config.current_user_method).to eq(:current_user)
  end

  it 'starts with nil stripe keys' do
    expect(config.stripe_api_key).to be_nil
    expect(config.stripe_webhook_secret).to be_nil
  end

  describe 'SubsEngine.configure' do
    it 'yields the configuration' do
      SubsEngine.configure do |c|
        c.default_currency = 'eur'
      end

      expect(SubsEngine.configuration.default_currency).to eq('eur')
    ensure
      SubsEngine.configuration.default_currency = 'usd'
    end
  end
end
