# frozen_string_literal: true

module SubsEngine
  module Handlers
    class PaymentSucceeded
      extend Dry::Initializer
      include Dry::Monads[:result]

      option :subscription_repository, default: -> { SubscriptionRepository.new }
      option :invoice_repository, default: -> { InvoiceRepository.new }

      def call(payload)
        @object = (payload['object'] || payload[:object]).deep_stringify_keys

        return Success(:no_subscription) unless @object['subscription']
        return Success(:already_synced) if invoice_exists?

        find_subscription.bind do
          persist_invoice
        end
      end

      private

      def invoice_exists?
        invoice_repository.find_by_stripe_id(@object['id']).some?
      end

      def find_subscription
        subscription_repository.find_by_stripe_id(@object['subscription'])
                               .to_result(:subscription_not_found)
                               .bind do |sub|
          @subscription = sub
          Success(sub)
        end
      end

      def persist_invoice
        invoice = Invoice.create!(
          customer: @subscription.customer,
          subscription: @subscription,
          stripe_invoice_id: @object['id'],
          status: :paid,
          amount_cents: @object['amount_paid'] || 0,
          currency: @object['currency'] || 'usd',
          period_start: parse_timestamp(@object['period_start']),
          period_end: parse_timestamp(@object['period_end']),
          paid_at: parse_timestamp(@object.dig('status_transitions', 'paid_at'))
        )

        persist_line_items(invoice)
        Success(invoice)
      end

      def persist_line_items(invoice)
        lines = @object['lines']
        return unless lines.is_a?(Hash)

        (lines['data'] || []).each { |line| create_line_item(invoice, line) }
      end

      def create_line_item(invoice, line)
        invoice.line_items.create!(
          description: line['description'] || 'Charge',
          amount_cents: line['amount'] || 0,
          currency: line['currency'] || 'usd',
          quantity: line['quantity'] || 1,
          line_type: detect_line_type(line)
        )
      end

      def detect_line_type(line)
        line['type'] == 'invoiceitem' && line['proration'] ? :proration : :subscription
      end

      def parse_timestamp(value)
        value ? Time.zone.at(value) : nil
      end
    end
  end
end
