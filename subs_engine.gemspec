# frozen_string_literal: true

require_relative 'lib/subs_engine/version'

Gem::Specification.new do |spec|
  spec.name        = 'subs_engine'
  spec.version     = SubsEngine::VERSION
  spec.authors     = ['navfa']
  spec.email       = ['navfastudios@proton.me']
  spec.homepage    = 'https://github.com/navfa/subs_engine'
  spec.summary     = 'Drop-in Rails 8 subscription billing engine'
  spec.description = 'A mountable Rails 8 engine for production-ready subscription billing ' \
                     'with Hotwire dashboards, usage metering, and Stripe webhooks.'
  spec.license     = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "#{spec.homepage}#readme"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 3.3.0'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'chartkick', '~> 5.0'
  spec.add_dependency 'dry-initializer', '~> 3.1'
  spec.add_dependency 'dry-monads', '~> 1.6'
  spec.add_dependency 'groupdate', '~> 6.0'
  spec.add_dependency 'prawn', '~> 2.5'
  spec.add_dependency 'prawn-table', '~> 0.2'
  spec.add_dependency 'pundit', '~> 2.4'
  spec.add_dependency 'rails', '~> 8.0'
  spec.add_dependency 'statesman', '~> 12.0'
  spec.add_dependency 'stripe', '>= 12', '< 20'
  spec.add_dependency 'turbo-rails', '~> 2.0'
  spec.add_dependency 'view_component', '~> 3.0'
end
