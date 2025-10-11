# frozen_string_literal: true

module SubsEngine
  class InvoiceComponent < ViewComponent::Base
    attr_reader :invoice

    def initialize(invoice:)
      super
      @invoice = invoice
    end

    def formatted_total
      Kernel.format('%<amount>.2f %<currency>s',
                    amount: invoice.amount_cents / 100.0,
                    currency: invoice.currency.upcase)
    end

    def status_badge_class
      "subs-badge subs-badge--#{invoice.status}"
    end

    def period_label
      return 'N/A' unless invoice.period_start

      "#{invoice.period_start.to_date} — #{invoice.period_end&.to_date}"
    end
  end
end
