# frozen_string_literal: true

module SubsEngine
  class PlanPolicy < ApplicationPolicy
    def deactivate?
      admin?
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope.active
      end
    end
  end
end
