# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.0] - 2025-10-31

### Added
- GitHub Actions CI pipeline with RSpec and RuboCop
- SimpleCov coverage reporting with 85% minimum threshold
- Configurable gateway (`config.gateway = :fake` for demo/testing)
- FakeGateway for Stripe-free local development
- Propshaft asset pipeline for the dummy app
- Subscription detail page with card grid layout
- ENV-driven configuration (`GLOBAL_CURRENCY`, `TRIAL_PERIOD_DAYS`)
- Demo app with seed data and auto-authenticated admin
- PR template, SECURITY.md, CONTRIBUTING.md
- README with screenshots, badges, and full documentation
- This CHANGELOG

### Changed
- Services use `SubsEngine.configuration.default_gateway` instead of hardcoded `StripeGateway.new`
- Subscription policies allow admin access for cancel and update
- Dashboard CSS rewritten with Linear/Stripe-inspired design (BEM naming)
- Cancel button changed from red button to ghost text link

### Fixed
- Missing `Failure[:transition_failed]` case in SubscriptionsController#destroy
- `SubscribeCustomer#activate` now handles transition failure
- `ChangePlan#update_on_stripe` guards nil `stripe_subscription_id`
- Chartkick "No charting libraries found" error (gem assets via Propshaft)

## [0.6.0] - 2025-10-27

### Added
- Billing dashboard with MRR, active subscriptions, and churn rate metrics
- MRR trend chart (Chartkick + Groupdate, last 12 months)
- Subscription table with Turbo Frame status filters and pagination
- Customer detail view with subscription history and invoice list
- Real-time dashboard updates via Turbo Stream broadcasts
- MetricCardComponent, MrrChartComponent, SubscriptionTableComponent, CustomerDetailComponent
- ListSubscriptions and FetchCustomerDetail services
- Dashboard lifecycle integration spec

## [0.5.0] - 2025-10-21

### Added
- UsageMetric and UsageRecord models (append-only)
- RecordUsage and AggregateUsage services
- SyncUsageToStripe service with idempotent `action: 'set'` reporting
- Metered line item detection in payment succeeded handler
- Usage metering lifecycle integration spec

### Changed
- Standardized all services with dry-initializer and bind chains
- Replaced hardcoded state strings with SubscriptionStateMachine constants

## [0.4.0] - 2025-10-11

### Added
- Invoice and InvoiceLineItem models with Stripe webhook sync
- Invoice PDF generation with Prawn
- InvoiceRepository with Maybe lookups
- ChangePlan service with Stripe proration
- Invoice controller with HTML and PDF responses
- Billing lifecycle integration spec

## [0.3.0] - 2025-10-10

### Added
- WebhookEvent model with idempotency index
- Stripe webhook controller with signature verification
- Async webhook processing via WebhookEventDispatcher
- PaymentSucceeded, PaymentFailed, SubscriptionUpdated, SubscriptionDeleted handlers
- Webhook lifecycle integration spec

## [0.2.0] - 2025-10-08

### Added
- Subscription model with Statesman state machine (trialing, active, past_due, canceled, expired)
- SubscribeCustomer and CancelSubscription services
- StripeGateway boundary for all Stripe API calls
- CreateStripeCustomer service
- Pundit policies for plans and subscriptions
- PlanCardComponent and SubscriptionStatusComponent
- Subscription lifecycle integration spec

### Changed
- Repositories return Maybe monads for nil-safe lookups
- Services use native pattern matching over dry-matcher

## [0.1.0] - 2025-10-01

### Added
- Mountable Rails 8 engine with isolated namespace
- Plan model with UUID primary keys, multi-currency support
- Customer model with Stripe reference
- PlansController with CRUD actions
- Repository pattern for all database access
- dry-monads Result type for service objects
- RSpec, RuboCop, factory_bot test infrastructure
- Billable concern for host app integration
- Configuration module and install generator
