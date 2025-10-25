# frozen_string_literal: true

module SubsEngine
  class CalculateMrrTrend
    extend Dry::Initializer
    include Dry::Monads[:result]

    DEFAULT_MONTHS = 12

    option :subscription_repository, default: -> { SubscriptionRepository.new }

    def call
      build_trend
    end

    private

    def build_trend
      data = subscription_repository.mrr_by_month(months: DEFAULT_MONTHS)
      Success(data)
    end
  end
end
