# frozen_string_literal: true

Rails.application.routes.draw do
  mount SubsEngine::Engine => '/billing'
end
