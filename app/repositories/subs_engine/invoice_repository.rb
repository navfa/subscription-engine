# frozen_string_literal: true

module SubsEngine
  class InvoiceRepository
    include Dry::Monads[:maybe]

    def find_by_id(id)
      Maybe(Invoice.includes(:line_items).find_by(id: id))
    end

    def find_by_stripe_id(stripe_invoice_id)
      Maybe(Invoice.find_by(stripe_invoice_id: stripe_invoice_id))
    end

    def find_by_customer(customer)
      Invoice.where(customer: customer).includes(:line_items).order(created_at: :desc)
    end

    def find_by_status(status)
      Invoice.where(status: status).includes(:line_items).order(created_at: :desc)
    end

    def find_recent(limit: 10)
      Invoice.includes(:line_items).recent(limit)
    end
  end
end
