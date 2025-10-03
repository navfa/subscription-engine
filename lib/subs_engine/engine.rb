# frozen_string_literal: true

module SubsEngine
  class Engine < ::Rails::Engine
    isolate_namespace SubsEngine

    %w[repositories state_machines gateways services].each do |dir|
      config.autoload_paths << root.join('app', dir)
    end

    initializer 'subs_engine.statesman' do
      Statesman.configure do
        storage_adapter(Statesman::Adapters::ActiveRecord)
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
    end
  end
end
