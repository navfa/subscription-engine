# frozen_string_literal: true

module SubsEngine
  class ListSubscriptions
    extend Dry::Initializer
    include Dry::Monads[:result]

    PER_PAGE = 20

    option :subscription_repository, default: -> { SubscriptionRepository.new }

    def call(status: nil, page: 1)
      @status = status
      @page = [page.to_i, 1].max

      fetch_subscriptions
    end

    private

    def fetch_subscriptions
      scope = if @status.present?
                subscription_repository.find_by_state(@status)
              else
                subscription_repository.find_all_with_details
              end
      records = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
      total = scope.count

      Success({ records: records, meta: { page: @page, total: total, per_page: PER_PAGE } })
    end
  end
end
