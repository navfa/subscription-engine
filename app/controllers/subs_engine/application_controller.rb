# frozen_string_literal: true

module SubsEngine
  class ApplicationController < ActionController::Base
    include Pundit::Authorization
    include Dry::Monads[:result]

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def pundit_user
      send(SubsEngine.configuration.current_user_method)
    end

    def user_not_authorized
      head :forbidden
    end
  end
end
