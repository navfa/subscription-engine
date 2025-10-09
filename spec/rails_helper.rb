# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('dummy/config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'factory_bot_rails'
require 'webmock/rspec'
require 'database_cleaner/active_record'
require 'view_component/test_helpers'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

Rails.application.config.view_component.test_controller = 'SubsEngine::ApplicationController'

RSpec.configure do |config|
  config.fixture_paths = [File.expand_path('fixtures', __dir__)]
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include ViewComponent::TestHelpers, type: :component

  FactoryBot.definition_file_paths = [File.expand_path('factories', __dir__)]
  FactoryBot.find_definitions

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end
