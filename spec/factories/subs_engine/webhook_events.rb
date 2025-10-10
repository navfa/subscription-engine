# frozen_string_literal: true

FactoryBot.define do
  factory :webhook_event, class: 'SubsEngine::WebhookEvent' do
    sequence(:stripe_event_id) { |n| "evt_test#{n}" }
    event_type { 'customer.subscription.updated' }
    status { :pending }
    payload { { 'id' => stripe_event_id, 'type' => event_type } }

    trait :processed do
      status { :processed }
    end

    trait :failed do
      status { :failed }
      error_message { 'Handler raised an error' }
    end
  end
end
