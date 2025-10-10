# frozen_string_literal: true

module SubsEngine
  class StripeWebhooksController < ActionController::Base # rubocop:disable Rails/ApplicationController
    skip_forgery_protection

    def create
      event = construct_event
      return head :bad_request unless event

      webhook_event = persist_event(event)
      return head :ok unless webhook_event

      ProcessWebhookEventJob.perform_later(webhook_event.id)
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

    def persist_event(event)
      webhook_event = WebhookEvent.create(
        stripe_event_id: event.id,
        event_type: event.type,
        payload: event.data.to_h
      )
      webhook_event.persisted? ? webhook_event : nil
    rescue ActiveRecord::RecordNotUnique
      nil
    end

    def webhook_secret
      SubsEngine.configuration.stripe_webhook_secret
    end
  end
end
