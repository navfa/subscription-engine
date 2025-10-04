# SubsEngine

A drop-in Rails 8 engine that gives every SaaS app production-ready subscription billing — complete with Hotwire dashboards, usage metering, and Stripe webhooks.

## Installation

Add to your Gemfile:

```ruby
gem 'subs_engine'
```

Run the install generator:

```bash
bundle install
bin/rails generate subs_engine:install
bin/rails db:migrate
```

This will:
- Copy the initializer to `config/initializers/subs_engine.rb`
- Mount the engine at `/billing`
- Run engine migrations

## Configuration

```ruby
# config/initializers/subs_engine.rb
SubsEngine.configure do |config|
  config.stripe_api_key = ENV.fetch('STRIPE_API_KEY')
  config.stripe_webhook_secret = ENV.fetch('STRIPE_WEBHOOK_SECRET')
  config.default_currency = 'usd'
  config.trial_period_days = 14
end
```

## Make Your User Billable

```ruby
class User < ApplicationRecord
  include SubsEngine::Billable
end
```

This gives you:

```ruby
user.billing_customer     # => SubsEngine::Customer
user.active_subscription  # => SubsEngine::Subscription
user.subscribed?          # => true/false
```

## Key Concepts

- **Plan** — a product offering with price, interval, and currency
- **Customer** — links your app's user to a Stripe customer
- **Subscription** — tracks the lifecycle: trialing → active → past_due → canceled → expired
- **State transitions** — auditable via Statesman, every change is recorded

## Architecture

- **Mountable engine** with full namespace isolation
- **dry-monads** for all service objects (Result types, no exceptions for business logic)
- **Statesman** for subscription state machine with transition history
- **Repository pattern** for database access
- **Stripe gateway** boundary (port/adapter pattern)

## Development

```bash
bundle install
bundle exec rake db:create db:migrate
bundle exec rspec
bundle exec rubocop
```

## License

MIT License. See [MIT-LICENSE](MIT-LICENSE).
