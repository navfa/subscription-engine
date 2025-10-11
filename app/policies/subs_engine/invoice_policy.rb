# frozen_string_literal: true

module SubsEngine
  class InvoicePolicy < ApplicationPolicy
    def show?
      owner? || admin?
    end

    private

    def owner?
      record.customer.external_id == user.id.to_s
    end
  end
end
