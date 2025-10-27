# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard lifecycle', type: :request do
  let(:user) { Struct.new(:id, :subs_engine_admin?).new(42, true) }
  let(:customer) { create(:customer, :with_stripe) }
  let(:plan) { create(:plan, :with_stripe, name: 'Pro', amount_cents: 2999) }

  before do
    sign_in_as(user)
    customer
    plan
  end

  it 'loads dashboard, filters subscriptions, and views customer detail' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    # Create an active subscription
    sub = create(:subscription, customer: customer, plan: plan)
    sub.transition_to(:active)
    create(:invoice, customer: customer, subscription: sub)

    # Load dashboard — verify metrics
    get subs_engine.dashboard_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Monthly Recurring Revenue')
    expect(response.body).to include('Active Subscriptions')
    expect(response.body).to include('Churn Rate')

    # Verify subscription table
    expect(response.body).to include(customer.email)
    expect(response.body).to include(plan.name)

    # Filter by active status
    get subs_engine.dashboard_path(status: 'active')
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(customer.email)

    # Filter by canceled — should be empty
    get subs_engine.dashboard_path(status: 'canceled')
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('No subscriptions found')

    # Click customer detail
    get subs_engine.customer_path(customer)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(customer.email)
    expect(response.body).to include(plan.name)
  end
end
