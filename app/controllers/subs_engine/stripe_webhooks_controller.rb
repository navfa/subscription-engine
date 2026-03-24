# frozen_string_literal: true

module SubsEngine
  class StripeWebhooksController < ActionController::Base # rubocop:disable Rails/ApplicationController
    skip_forgery_protection

    def create
      event = construct_event
      return head :bad_request unless event

      result = RecordWebhookEvent.new.call(event)

      case result
      in Dry::Monads::Success(webhook_event)
        ProcessWebhookEventJob.perform_later(webhook_event.id)
      in Dry::Monads::Failure[:duplicate | :invalid]
        nil
      end

      head :ok
    end

    private

    def construct_event
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    rescue Stripe::SignatureVerificationError, JSON::ParserError
      nil
    end

    def webhook_secret
      SubsEngine.configuration.stripe_webhook_secret
    end
  end
end
