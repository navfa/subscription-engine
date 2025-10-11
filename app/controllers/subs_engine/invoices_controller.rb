# frozen_string_literal: true

module SubsEngine
  class InvoicesController < ApplicationController
    before_action :set_invoice, only: [:show]

    def index
      customer = customer_repository.find_by_external_id(pundit_user.id.to_s).value_or do
        return head :not_found
      end

      @invoices = invoice_repository.find_by_customer(customer)
    end

    def show
      authorize @invoice, policy_class: InvoicePolicy

      respond_to do |format|
        format.html
        format.pdf { send_pdf }
      end
    end

    private

    def set_invoice
      @invoice = invoice_repository.find_by_id(params[:id]).value_or do
        raise ActiveRecord::RecordNotFound
      end
    end

    def send_pdf
      result = GenerateInvoicePdf.new.call(@invoice)
      send_data result.value!,
                filename: "invoice-#{@invoice.stripe_invoice_id}.pdf",
                type: 'application/pdf',
                disposition: 'inline'
    end

    def customer_repository
      @customer_repository ||= CustomerRepository.new
    end

    def invoice_repository
      @invoice_repository ||= InvoiceRepository.new
    end
  end
end
