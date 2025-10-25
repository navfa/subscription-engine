# frozen_string_literal: true

module SubsEngine
  class CalculateActiveCount
    extend Dry::Initializer
    include Dry::Monads[:result]

    option :subscription_repository, default: -> { SubscriptionRepository.new }

    def call
      count_active
    end

    private

    def count_active
      Success(subscription_repository.find_all_active.count)
    end
  end
end
