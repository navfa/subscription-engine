# frozen_string_literal: true

module SubsEngine
  class Engine < ::Rails::Engine
    isolate_namespace SubsEngine

    config.autoload_paths << root.join('app', 'repositories')
    config.autoload_paths << root.join('app', 'state_machines')

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
