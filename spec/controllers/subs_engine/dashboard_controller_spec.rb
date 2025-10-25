# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::DashboardController, type: :controller do
  routes { SubsEngine::Engine.routes }

  let(:user) { double('User', id: 42, subs_engine_admin?: true) }

  before { allow(controller).to receive(:pundit_user).and_return(user) }

  describe 'GET #index' do
    it 'renders successfully' do
      get :index

      expect(response).to have_http_status(:ok)
    end
  end
end
