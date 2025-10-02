# frozen_string_literal: true

FactoryBot.define do
  factory :plan, class: 'SubsEngine::Plan' do
    name { 'Starter' }
    sequence(:slug) { |n| "starter-#{n}" }
    interval { :monthly }
    amount_cents { 1999 }
    currency { 'usd' }
    active { true }

    trait :yearly do
      interval { :yearly }
      amount_cents { 19_900 }
    end

    trait :inactive do
      active { false }
    end

    trait :free do
      name { 'Free' }
      amount_cents { 0 }
    end
  end
end
