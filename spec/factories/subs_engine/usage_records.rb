# frozen_string_literal: true

FactoryBot.define do
  factory :usage_record, class: 'SubsEngine::UsageRecord' do
    association :customer
    association :usage_metric
    quantity { 1 }
    recorded_at { Time.current }
  end
end
