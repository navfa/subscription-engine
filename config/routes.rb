# frozen_string_literal: true

SubsEngine::Engine.routes.draw do
  resources :plans, except: [:destroy] do
    member do
      patch :deactivate
    end
  end

  resources :subscriptions, only: [:show, :create, :update, :destroy]
  resources :invoices, only: [:index, :show]

  post 'webhooks/stripe', to: 'stripe_webhooks#create'
end
