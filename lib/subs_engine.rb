# frozen_string_literal: true

require 'dry/initializer'
require 'dry/monads'
require 'pundit'
require 'statesman'
require 'stripe'
require 'view_component'
require 'prawn'
require 'prawn/table'

require 'subs_engine/configuration'
require 'subs_engine/version'
require 'subs_engine/engine'

module SubsEngine
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
