# frozen_string_literal: true

FactoryBot.define do
  factory :customer, class: 'SubsEngine::Customer' do
    sequence(:external_id) { |n| "user_#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    stripe_customer_id { nil }

    trait :with_stripe do
      sequence(:stripe_customer_id) { |n| "cus_test#{n}" }
    end
  end
end
