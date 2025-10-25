# frozen_string_literal: true

module SubsEngine
  class CustomersController < ApplicationController
    def show
      case FetchCustomerDetail.new.call(customer_id: params[:id])
      in Success(detail)
        @customer = detail[:customer]
        @subscriptions = detail[:subscriptions]
        @invoices = detail[:invoices]
      in Failure[:customer_not_found]
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
