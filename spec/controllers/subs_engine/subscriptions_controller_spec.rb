# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::SubscriptionsController, type: :controller do
  routes { SubsEngine::Engine.routes }

  let(:user) { double('User', id: 42, subs_engine_admin?: false) }

  before { allow(controller).to receive(:pundit_user).and_return(user) }

  describe 'GET #show' do
    let(:customer) { create(:customer, external_id: '42') }
    let(:subscription) { create(:subscription, customer: customer) }

    it 'renders the subscription' do
      get :show, params: { id: subscription.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    let(:customer) { create(:customer, :with_stripe, external_id: '42') }
    let(:plan) { create(:plan, :with_stripe) }
    let(:stripe_sub) { Struct.new(:id, :status).new('sub_new', 'active') }

    before do
      customer
      allow(Stripe::Subscription).to receive(:create).and_return(stripe_sub)
    end

    it 'creates a subscription and redirects' do
      post :create, params: { plan_id: plan.id }

      expect(response).to have_http_status(:redirect)
    end

    context 'when plan does not exist' do
      it 'returns not found' do
        post :create, params: { plan_id: SecureRandom.uuid }

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when customer does not exist' do
      let(:user) { double('User', id: 999, subs_engine_admin?: false) }

      it 'returns not found' do
        post :create, params: { plan_id: plan.id }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH #update' do
    let(:customer) { create(:customer, :with_stripe, external_id: '42') }
    let(:subscription) { create(:subscription, :with_stripe, customer: customer) }
    let(:new_plan) { create(:plan, :with_stripe, name: 'Pro', stripe_price_id: 'price_pro') }

    before do
      subscription.transition_to(:active)
      stripe_sub = Struct.new(:id, :status, :items).new(
        subscription.stripe_subscription_id,
        'active',
        Struct.new(:data).new([Struct.new(:id).new('si_123')])
      )
      allow(Stripe::Subscription).to receive_messages(retrieve: stripe_sub, update: stripe_sub)
    end

    it 'changes the plan and redirects' do
      patch :update, params: { id: subscription.id, subscription: { plan_id: new_plan.id } }

      expect(response).to have_http_status(:redirect)
      expect(subscription.reload.plan).to eq(new_plan)
    end

    it 'rejects changing to the same plan' do
      patch :update, params: { id: subscription.id, subscription: { plan_id: subscription.plan_id } }

      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq(I18n.t('subs_engine.subscriptions.same_plan'))
    end
  end

  describe 'DELETE #destroy' do
    let(:customer) { create(:customer, :with_stripe, external_id: '42') }
    let(:subscription) { create(:subscription, :with_stripe, customer: customer) }
    let(:canceled_sub) { Struct.new(:id, :status).new('sub_test1', 'canceled') }

    before do
      subscription.transition_to(:active)
      allow(Stripe::Subscription).to receive(:cancel).and_return(canceled_sub)
    end

    it 'cancels the subscription and redirects' do
      delete :destroy, params: { id: subscription.id }

      expect(response).to have_http_status(:redirect)
      expect(subscription.current_state).to eq('canceled')
    end
  end
end
