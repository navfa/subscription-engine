# frozen_string_literal: true

module SubsEngine
  class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      true
    end

    def show?
      true
    end

    def create?
      admin?
    end

    def new?
      create?
    end

    def update?
      admin?
    end

    def edit?
      update?
    end

    def destroy?
      admin?
    end

    private

    def admin?
      user.respond_to?(:subs_engine_admin?) && user.subs_engine_admin?
    end
  end
end
