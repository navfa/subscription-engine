# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::PlansController, type: :controller do
  routes { SubsEngine::Engine.routes }

  describe 'GET #index' do
    it 'renders successfully' do
      create(:plan, active: true)

      get :index

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'renders the plan' do
      plan = create(:plan)

      get :show, params: { id: plan.id }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #new' do
    it 'renders the form' do
      get :new

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      { plan: { name: 'Pro', slug: 'pro', interval: 'monthly', amount_cents: 2999, currency: 'usd' } }
    end

    context 'with valid params' do
      it 'creates the plan and redirects' do
        expect { post :create, params: valid_params }
          .to change(SubsEngine::Plan, :count).by(1)

        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      it 'renders new with errors' do
        post :create, params: { plan: { name: '', slug: '' } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH #update' do
    let(:plan) { create(:plan) }

    context 'with valid params' do
      it 'updates the plan and redirects' do
        patch :update, params: { id: plan.id, plan: { name: 'Updated' } }

        expect(plan.reload.name).to eq('Updated')
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'with invalid params' do
      it 'renders edit with errors' do
        patch :update, params: { id: plan.id, plan: { name: '' } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH #deactivate' do
    it 'deactivates the plan and redirects' do
      plan = create(:plan, active: true)

      patch :deactivate, params: { id: plan.id }

      expect(plan.reload.active).to be(false)
      expect(response).to have_http_status(:redirect)
    end
  end
end
