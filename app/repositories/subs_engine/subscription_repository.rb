# frozen_string_literal: true

module SubsEngine
  class SubscriptionRepository
    include Dry::Monads[:maybe]

    def find_by_id(id)
      Maybe(Subscription.find_by(id: id))
    end

    def find_active_by_customer(customer)
      Subscription.where(customer: customer).in_state(:active)
    end

    def find_by_stripe_id(stripe_subscription_id)
      Maybe(Subscription.find_by(stripe_subscription_id: stripe_subscription_id))
    end

    def find_active_metered
      Subscription.in_state(:active)
                  .where.not(stripe_subscription_item_id: nil)
                  .includes(:customer)
    end

    def find_all_active
      Subscription.in_state(:active)
    end

    def count_active_at(timestamp)
      Subscription.where(created_at: ..timestamp)
                  .where('canceled_at IS NULL OR canceled_at > ?', timestamp)
                  .count
    end

    def count_canceled_between(period_start, period_end)
      Subscription.in_state(:canceled)
                  .where(canceled_at: period_start..period_end)
                  .count
    end

    def mrr_by_month(months: 12)
      Subscription.in_state(:active)
                  .joins(:plan)
                  .group_by_month(:created_at, last: months, format: '%b %Y')
                  .sum('subs_engine_plans.amount_cents')
    end
  end
end
