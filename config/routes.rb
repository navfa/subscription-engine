# frozen_string_literal: true

SubsEngine::Engine.routes.draw do
  resources :plans, except: [:destroy] do
    member do
      patch :deactivate
    end
  end
end
