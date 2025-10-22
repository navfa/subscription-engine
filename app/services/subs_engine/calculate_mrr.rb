# frozen_string_literal: true

module SubsEngine
  class CalculateMrr
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :subscription_repository, default: -> { SubscriptionRepository.new }

    def call
      sum_active_plans
    end

    private

    def sum_active_plans
      mrr = subscription_repository.find_all_active
                                   .joins(:plan)
                                   .sum('subs_engine_plans.amount_cents')
      Success(mrr)
    end
  end
end
