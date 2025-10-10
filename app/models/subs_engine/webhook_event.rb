# frozen_string_literal: true

module SubsEngine
  class WebhookEvent < ApplicationRecord
    enum :status, { pending: 0, processed: 1, failed: 2 }

    validates :stripe_event_id, presence: true, uniqueness: true
    validates :event_type, presence: true

    def mark_processed!
      update!(status: :processed)
    end

    def mark_failed!(message)
      update!(status: :failed, error_message: message)
    end
  end
end
