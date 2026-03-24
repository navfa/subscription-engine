# frozen_string_literal: true

module SubsEngine
  class RecordWebhookEvent
    include Dry::Monads[:result]

    def call(stripe_event)
      @stripe_event = stripe_event

      create_event
    rescue ActiveRecord::RecordNotUnique
      Failure(:duplicate)
    end

    private

    def create_event
      record = WebhookEvent.create(
        stripe_event_id: @stripe_event.id,
        event_type: @stripe_event.type,
        payload: @stripe_event.data.to_h
      )

      return Success(record) if record.persisted?

      record.errors[:stripe_event_id].any? ? Failure(:duplicate) : Failure(:invalid)
    end
  end
end
