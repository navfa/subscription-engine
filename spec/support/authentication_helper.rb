# frozen_string_literal: true

module AuthenticationHelper
  def sign_in_as(user)
    SubsEngine::ApplicationController.define_method(:current_user) { user }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request

  config.after(:each, type: :request) do
    if SubsEngine::ApplicationController.method_defined?(:current_user)
      SubsEngine::ApplicationController.remove_method(:current_user)
    end
  end
end
