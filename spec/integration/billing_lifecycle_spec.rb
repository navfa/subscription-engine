# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Billing lifecycle', type: :request do
  let(:user) { Struct.new(:id, :subs_engine_admin?).new(42, false) }
  let(:customer) { create(:customer, :with_stripe, external_id: '42') }
  let(:starter_plan) { create(:plan, :with_stripe, name: 'Starter', amount_cents: 999) }
  let(:pro_plan) { create(:plan, :with_stripe, name: 'Pro', amount_cents: 2999, stripe_price_id: 'price_pro') }
  let(:stripe_sub) do
    Struct.new(:id, :status, :items).new(
      'sub_billing',
      'active',
      Struct.new(:data).new([Struct.new(:id).new('si_123')])
    )
  end

  before do
    sign_in_as(user)
    customer
    starter_plan
    pro_plan
    allow(Stripe::Subscription).to receive_messages(create: stripe_sub, retrieve: stripe_sub, update: stripe_sub)
  end

  it 'subscribes, receives an invoice, changes plan, and views invoices' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    # Subscribe to the starter plan
    post subs_engine.subscriptions_path(plan_id: starter_plan.id)
    subscription = SubsEngine::Subscription.last
    expect(subscription.current_state).to eq('active')

    # Simulate a payment_succeeded webhook creating an invoice
    payment_payload = {
      'object' => {
        'id' => 'in_billing_1',
        'subscription' => subscription.stripe_subscription_id,
        'amount_paid' => 999,
        'currency' => 'usd',
        'period_start' => 1_696_118_400,
        'period_end' => 1_698_796_800,
        'lines' => {
          'data' => [
            { 'description' => 'Starter plan', 'amount' => 999, 'currency' => 'usd', 'quantity' => 1 }
          ]
        }
      }
    }
    result = SubsEngine::Handlers::PaymentSucceeded.new.call(payment_payload)
    expect(result).to be_success
    expect(SubsEngine::Invoice.count).to eq(1)

    # Change to pro plan
    patch subs_engine.subscription_path(subscription), params: { subscription: { plan_id: pro_plan.id } }
    expect(subscription.reload.plan).to eq(pro_plan)

    # View invoices list
    get subs_engine.invoices_path
    expect(response).to have_http_status(:ok)

    # View invoice detail
    invoice = SubsEngine::Invoice.last
    get subs_engine.invoice_path(invoice)
    expect(response).to have_http_status(:ok)

    # Download PDF
    get subs_engine.invoice_path(invoice, format: :pdf)
    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include('application/pdf')
  end
end
