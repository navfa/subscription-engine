# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DemoAuthentication
  helper_method :current_user
end
