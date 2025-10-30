# frozen_string_literal: true

module SubsEngine
  class CustomerDetailComponent < ViewComponent::Base
    include Turbo::FramesHelper

    attr_reader :customer, :subscriptions, :invoices

    def initialize(customer:, subscriptions:, invoices:)
      super
      @customer = customer
      @subscriptions = subscriptions
      @invoices = invoices
    end
  end
end
