# frozen_string_literal: true

module SubsEngine
  class WebhookEventRepository
    include Dry::Monads[:maybe]

    def find_by_id(id)
      Maybe(WebhookEvent.find_by(id: id))
    end

    def find_by_stripe_event_id(stripe_event_id)
      Maybe(WebhookEvent.find_by(stripe_event_id: stripe_event_id))
    end
  end
end
