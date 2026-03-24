# frozen_string_literal: true

module SubsEngine
  class ProcessWebhookEventJob < ApplicationJob
    queue_as :webhooks

    def perform(webhook_event_id)
      event = WebhookEventRepository.new.find_by_id(webhook_event_id) # rubocop:disable Rails/DynamicFindBy
      return if event.none?

      event = event.value!
      return if event.processed?

      result = WebhookEventDispatcher.new.call(event)

      case result
      in Dry::Monads::Success
        event.mark_processed!
      in Dry::Monads::Failure[*, message]
        event.mark_failed!(message.to_s)
      end
    end
  end
end
