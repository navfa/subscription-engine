# frozen_string_literal: true

module SubsEngine
  class CalculateChurnRate
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :subscription_repository, default: -> { SubscriptionRepository.new }

    def call(period_start:, period_end:)
      @period_start = period_start
      @period_end = period_end

      calculate
    end

    private

    def calculate
      active_at_start = subscription_repository.count_active_at(@period_start)
      return Success(0.0) if active_at_start.zero?

      canceled_in_period = subscription_repository.count_canceled_between(@period_start, @period_end)
      rate = (canceled_in_period.to_f / active_at_start * 100).round(1)

      Success(rate)
    end
  end
end
