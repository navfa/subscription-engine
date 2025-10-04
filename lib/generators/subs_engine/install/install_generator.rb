# frozen_string_literal: true

module SubsEngine
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_initializer
        template 'initializer.rb', 'config/initializers/subs_engine.rb'
      end

      def mount_engine
        route "mount SubsEngine::Engine => '/billing'"
      end
    end
  end
end
