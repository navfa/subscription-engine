# frozen_string_literal: true

FactoryBot.define do
  factory :usage_metric, class: 'SubsEngine::UsageMetric' do
    name { 'API Calls' }
    sequence(:code) { |n| "api_calls_#{n}" }
    unit { 'calls' }
    active { true }

    trait :with_stripe do
      sequence(:stripe_price_id) { |n| "price_metered_#{n}" }
    end

    trait :inactive do
      active { false }
    end
  end
end
