# frozen_string_literal: true

module SubsEngine
  class SubscriptionPolicy < ApplicationPolicy
    def show?
      owner? || admin?
    end

    def cancel?
      owner?
    end

    def destroy?
      cancel?
    end

    private

    def owner?
      record.customer.external_id == user.id.to_s
    end
  end
end
