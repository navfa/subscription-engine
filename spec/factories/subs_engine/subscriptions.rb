# frozen_string_literal: true

FactoryBot.define do
  factory :subscription, class: 'SubsEngine::Subscription' do
    association :customer
    association :plan
    current_period_start { Time.current }
    current_period_end { 1.month.from_now }

    trait :trialing do
      trial_end { 14.days.from_now }
    end

    trait :with_stripe do
      sequence(:stripe_subscription_id) { |n| "sub_test#{n}" }
    end
  end

  factory :subscription_transition, class: 'SubsEngine::SubscriptionTransition' do
    association :subscription
    to_state { 'active' }
    sort_key { 1 }
    most_recent { true }
  end
end
