# frozen_string_literal: true

FactoryBot.define do
  factory :invoice, class: 'SubsEngine::Invoice' do
    association :customer
    association :subscription
    sequence(:stripe_invoice_id) { |n| "in_test#{n}" }
    status { :draft }
    amount_cents { 1999 }
    currency { 'usd' }
    period_start { Time.current.beginning_of_month }
    period_end { Time.current.end_of_month }

    trait :paid do
      status { :paid }
      paid_at { Time.current }
    end

    trait :open do
      status { :open }
    end

    trait :void do
      status { :void }
    end
  end

  factory :invoice_line_item, class: 'SubsEngine::InvoiceLineItem' do
    association :invoice
    description { 'Starter plan — monthly' }
    amount_cents { 1999 }
    currency { 'usd' }
    quantity { 1 }
    line_type { :subscription }

    trait :proration do
      description { 'Proration credit' }
      line_type { :proration }
    end

    trait :usage do
      description { 'API calls — 1000 units' }
      line_type { :usage }
    end
  end
end
