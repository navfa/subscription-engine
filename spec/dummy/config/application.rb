# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)
require 'subs_engine'

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.0
    config.eager_load = false
  end
end
