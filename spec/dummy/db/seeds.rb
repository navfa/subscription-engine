# frozen_string_literal: true

# rubocop:disable Rails/Output,Metrics/BlockLength

puts '🌱 Seeding SubsEngine demo data...'

ActiveRecord::Base.transaction do # rubocop:disable Metrics/BlockLength
  now = Time.current

  # ─── Plans (4 records — need AR objects for FKs) ────────

  plan_attrs = [
    { slug: 'starter',      name: 'Starter',      amount_cents: 2900,  stripe_price_id: 'price_starter_monthly',    active: true },
    { slug: 'pro',          name: 'Pro',           amount_cents: 7900,  stripe_price_id: 'price_pro_monthly',        active: true },
    { slug: 'enterprise',   name: 'Enterprise',    amount_cents: 24900, stripe_price_id: 'price_enterprise_monthly', active: true },
    { slug: 'legacy-basic', name: 'Legacy Basic',  amount_cents: 999,   stripe_price_id: 'price_legacy_basic',       active: false }
  ]

  plan_attrs.each do |plan_data|
    SubsEngine::Plan.find_or_create_by!(slug: plan_data[:slug]) do |plan|
      plan.assign_attributes(plan_data.merge(currency: 'usd', interval: :monthly))
    end
  end

  plans = SubsEngine::Plan.where(slug: plan_attrs.pluck(:slug)).index_by(&:slug)
  puts "  ✓ #{SubsEngine::Plan.count} plans"

  # ─── Customers (bulk upsert) ───────────────────────────

  customer_rows = [
    { external_id: 'usr_acme',      email: 'billing@acme.io',          stripe_customer_id: 'cus_acme' },
    { external_id: 'usr_initech',   email: 'ops@initech.com',          stripe_customer_id: 'cus_initech' },
    { external_id: 'usr_hooli',     email: 'finance@hooli.xyz',        stripe_customer_id: 'cus_hooli' },
    { external_id: 'usr_piedpiper', email: 'richard@piedpiper.com',    stripe_customer_id: 'cus_piedpiper' },
    { external_id: 'usr_waystar',   email: 'accounting@waystar.co',    stripe_customer_id: 'cus_waystar' },
    { external_id: 'usr_sterling',  email: 'joan@sterling-cooper.com', stripe_customer_id: 'cus_sterling' },
    { external_id: 'usr_dunder',    email: 'michael@dundermifflin.com', stripe_customer_id: 'cus_dunder' },
    { external_id: 'usr_umbrella',  email: 'albert@umbrella-corp.net', stripe_customer_id: 'cus_umbrella' },
    { external_id: 'usr_stark',     email: 'pepper@stark-ind.com',     stripe_customer_id: 'cus_stark' },
    { external_id: 'usr_wonka',     email: 'willy@wonka-factory.com',  stripe_customer_id: 'cus_wonka' },
    { external_id: 'usr_cyberdyne', email: 'miles@cyberdyne.io',       stripe_customer_id: 'cus_cyberdyne' },
    { external_id: 'usr_weyland',   email: 'peter@weyland-corp.com',   stripe_customer_id: 'cus_weyland' }
  ]

  SubsEngine::Customer.upsert_all(
    customer_rows.map { |row| row.merge(created_at: now, updated_at: now) },
    unique_by: :external_id
  )

  customers = SubsEngine::Customer.where(external_id: customer_rows.pluck(:external_id))
                                   .index_by(&:external_id)
  puts "  ✓ #{SubsEngine::Customer.count} customers"

  # ─── Subscriptions (individual — Statesman needs transitions) ──

  subscription_defs = [
    { customer_key: 'usr_acme',      plan_slug: 'enterprise', state: :active,   created_ago: 11.months },
    { customer_key: 'usr_initech',   plan_slug: 'pro',        state: :active,   created_ago: 10.months },
    { customer_key: 'usr_hooli',     plan_slug: 'enterprise', state: :active,   created_ago: 9.months },
    { customer_key: 'usr_piedpiper', plan_slug: 'starter',    state: :active,   created_ago: 8.months },
    { customer_key: 'usr_waystar',   plan_slug: 'pro',        state: :active,   created_ago: 7.months },
    { customer_key: 'usr_sterling',  plan_slug: 'starter',    state: :active,   created_ago: 5.months },
    { customer_key: 'usr_dunder',    plan_slug: 'pro',        state: :past_due, created_ago: 6.months },
    { customer_key: 'usr_umbrella',  plan_slug: 'starter',    state: :canceled, created_ago: 4.months, canceled_ago: 15.days },
    { customer_key: 'usr_stark',     plan_slug: 'enterprise', state: :active,   created_ago: 3.months },
    { customer_key: 'usr_wonka',     plan_slug: 'pro',        state: :active,   created_ago: 2.months },
    { customer_key: 'usr_cyberdyne', plan_slug: 'pro',        state: :canceled, created_ago: 8.months, canceled_ago: 45.days },
    { customer_key: 'usr_weyland',   plan_slug: 'starter',    state: :canceled, created_ago: 6.months, canceled_ago: 60.days }
  ]

  subscriptions = subscription_defs.map do |definition|
    customer = customers.fetch(definition[:customer_key])
    plan = plans.fetch(definition[:plan_slug])

    subscription = SubsEngine::Subscription.find_or_initialize_by(customer: customer, plan: plan)
    next subscription unless subscription.new_record?

    subscription.assign_attributes(
      stripe_subscription_id: "sub_#{definition[:customer_key]}_#{definition[:plan_slug]}",
      stripe_subscription_item_id: "si_#{definition[:customer_key]}_#{definition[:plan_slug]}",
      current_period_start: definition[:created_ago].ago.beginning_of_month,
      current_period_end: definition[:created_ago].ago.beginning_of_month + 1.month,
      created_at: definition[:created_ago].ago
    )
    subscription.save!
    subscription.transition_to(:active)

    case definition[:state]
    when :past_due then subscription.transition_to(:past_due)
    when :canceled
      subscription.transition_to(:canceled)
      subscription.update!(canceled_at: definition[:canceled_ago].ago)
    end

    subscription
  end

  active_count = SubsEngine::Subscription.in_state(:active).count
  past_due_count = SubsEngine::Subscription.in_state(:past_due).count
  canceled_count = SubsEngine::Subscription.in_state(:canceled).count
  puts "  ✓ #{subscriptions.size} subscriptions (#{active_count} active, #{past_due_count} past_due, #{canceled_count} canceled)"

  # ─── Invoices + Line Items (bulk insert) ───────────────

  existing_invoice_ids = SubsEngine::Invoice.pluck(:stripe_invoice_id).to_set

  invoice_rows = []
  subscriptions.each do |subscription|
    months_active = ((now - subscription.created_at) / 1.month).floor
    months_active.times do |month_index|
      stripe_invoice_id = "in_#{subscription.stripe_subscription_id}_#{month_index}"
      next if existing_invoice_ids.include?(stripe_invoice_id)

      period_start = subscription.created_at + month_index.months

      invoice_rows << {
        customer_id: subscription.customer_id,
        subscription_id: subscription.id,
        stripe_invoice_id: stripe_invoice_id,
        amount_cents: subscription.plan.amount_cents,
        currency: subscription.plan.currency,
        period_start: period_start,
        period_end: period_start + 1.month,
        status: :paid,
        paid_at: period_start + 1.day,
        created_at: period_start,
        updated_at: now
      }
    end
  end

  SubsEngine::Invoice.insert_all(invoice_rows) if invoice_rows.any?

  new_invoices = SubsEngine::Invoice.where(stripe_invoice_id: invoice_rows.pluck(:stripe_invoice_id))
                                     .includes(subscription: :plan)

  line_item_rows = new_invoices.map do |invoice|
    {
      invoice_id: invoice.id,
      description: "#{invoice.subscription.plan.name} — monthly subscription",
      amount_cents: invoice.amount_cents,
      currency: invoice.currency,
      quantity: 1,
      line_type: :subscription,
      created_at: now,
      updated_at: now
    }
  end

  SubsEngine::InvoiceLineItem.insert_all(line_item_rows) if line_item_rows.any?

  puts "  ✓ #{SubsEngine::Invoice.count} invoices with line items"

  # ─── Usage Metrics ─────────────────────────────────────

  metric_attrs = [
    { code: 'api_calls',  name: 'API Calls', unit: 'calls', stripe_price_id: 'price_metered_api' },
    { code: 'storage_gb', name: 'Storage',   unit: 'GB',    stripe_price_id: 'price_metered_storage' }
  ]

  SubsEngine::UsageMetric.upsert_all(
    metric_attrs.map { |attrs| attrs.merge(active: true, created_at: now, updated_at: now) },
    unique_by: :code
  )

  metrics = SubsEngine::UsageMetric.where(code: %w[api_calls storage_gb]).index_by(&:code)
  puts "  ✓ #{SubsEngine::UsageMetric.count} usage metrics"

  # ─── Usage Records (bulk insert — heaviest table) ──────

  active_subscriptions = subscriptions.select { |sub| sub.current_state == SubsEngine::SubscriptionStateMachine::ACTIVE }

  usage_rows = []
  active_subscriptions.each do |subscription|
    30.times do |day_offset|
      recorded_at = day_offset.days.ago

      usage_rows << {
        customer_id: subscription.customer_id,
        usage_metric_id: metrics['api_calls'].id,
        quantity: rand(50..500),
        recorded_at: recorded_at,
        metadata: {},
        created_at: now,
        updated_at: now
      }

      next unless (day_offset % 7).zero?

      usage_rows << {
        customer_id: subscription.customer_id,
        usage_metric_id: metrics['storage_gb'].id,
        quantity: rand(1..10),
        recorded_at: recorded_at,
        metadata: {},
        created_at: now,
        updated_at: now
      }
    end
  end

  if usage_rows.any?
    existing_usage_count = SubsEngine::UsageRecord.count
    SubsEngine::UsageRecord.insert_all(usage_rows) if existing_usage_count.zero?
  end
  puts "  ✓ #{SubsEngine::UsageRecord.count} usage records"

  # ─── Webhook Events (bulk insert) ──────────────────────

  webhook_types = %w[
    invoice.payment_succeeded
    invoice.payment_succeeded
    customer.subscription.updated
    invoice.payment_failed
    customer.subscription.deleted
  ]

  webhook_rows = []
  subscriptions.first(5).each_with_index do |subscription, sub_index|
    webhook_types.each_with_index do |event_type, event_index|
      webhook_rows << {
        stripe_event_id: "evt_seed_#{sub_index}_#{event_index}",
        event_type: event_type,
        payload: { 'object' => { 'id' => subscription.stripe_subscription_id } },
        status: :processed,
        error_message: nil,
        created_at: (30 - (sub_index * 5) - event_index).days.ago,
        updated_at: now
      }
    end
  end

  webhook_rows << {
    stripe_event_id: 'evt_seed_pending',
    event_type: 'invoice.payment_succeeded',
    payload: { 'object' => { 'id' => 'in_unknown' } },
    status: :pending,
    error_message: nil,
    created_at: now,
    updated_at: now
  }

  webhook_rows << {
    stripe_event_id: 'evt_seed_failed',
    event_type: 'customer.subscription.updated',
    payload: { 'object' => { 'id' => 'sub_unknown' } },
    status: :failed,
    error_message: 'subscription_not_found',
    created_at: now,
    updated_at: now
  }

  SubsEngine::WebhookEvent.insert_all(webhook_rows)
  puts "  ✓ #{SubsEngine::WebhookEvent.count} webhook events"
end

puts ''
puts '✅ Seeding complete!'
puts '   Dashboard: http://localhost:3000/billing/dashboard'

# rubocop:enable Rails/Output,Metrics/BlockLength
