# frozen_string_literal: true

module SubsEngine
  module Handlers
    class PaymentSucceeded
      include Dry::Monads[:result, :do]

      def call(payload)
        object = (payload['object'] || payload[:object]).deep_stringify_keys
        stripe_sub_id = object['subscription']
        return Success(:no_subscription) unless stripe_sub_id
        return Success(:already_synced) if invoice_exists?(object['id'])

        subscription = yield find_subscription(stripe_sub_id)
        persist_invoice(subscription, object)
      end

      private

      def invoice_exists?(stripe_invoice_id)
        invoice_repository.find_by_stripe_id(stripe_invoice_id).some?
      end

      def find_subscription(stripe_sub_id)
        subscription_repository.find_by_stripe_id(stripe_sub_id)
                               .to_result(:subscription_not_found)
      end

      def persist_invoice(subscription, object)
        invoice = Invoice.create!(
          customer: subscription.customer,
          subscription: subscription,
          stripe_invoice_id: object['id'],
          status: :paid,
          amount_cents: object['amount_paid'] || 0,
          currency: object['currency'] || 'usd',
          period_start: parse_timestamp(object['period_start']),
          period_end: parse_timestamp(object['period_end']),
          paid_at: parse_timestamp(object.dig('status_transitions', 'paid_at'))
        )

        persist_line_items(invoice, object['lines'])
        Success(invoice)
      end

      def persist_line_items(invoice, lines)
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

      def subscription_repository
        @subscription_repository ||= SubscriptionRepository.new
      end

      def invoice_repository
        @invoice_repository ||= InvoiceRepository.new
      end
    end
  end
end
