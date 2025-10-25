# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::CustomersController, type: :controller do
  routes { SubsEngine::Engine.routes }

  let(:user) { double('User', id: 42, subs_engine_admin?: true) }

  before { allow(controller).to receive(:pundit_user).and_return(user) }

  describe 'GET #show' do
    context 'with existing customer' do
      let(:customer) { create(:customer) }

      it 'renders successfully' do
        get :show, params: { id: customer.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with unknown customer' do
      it 'raises not found' do
        expect { get :show, params: { id: 0 } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
