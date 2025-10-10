# frozen_string_literal: true

module SubsEngine
  class WebhookEventDispatcher
    include Dry::Monads[:result]

    HANDLERS = {
      'customer.subscription.updated' => 'SubsEngine::Handlers::SubscriptionUpdated',
      'customer.subscription.deleted' => 'SubsEngine::Handlers::SubscriptionDeleted',
      'invoice.payment_succeeded' => 'SubsEngine::Handlers::PaymentSucceeded',
      'invoice.payment_failed' => 'SubsEngine::Handlers::PaymentFailed'
    }.freeze

    def call(event)
      handler_class = HANDLERS[event.event_type]
      return Success(:ignored) unless handler_class

      handler_class.constantize.new.call(event.payload)
    end
  end
end
