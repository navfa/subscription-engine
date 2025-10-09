# frozen_string_literal: true

module SubsEngine
  class PlanCardComponent < ViewComponent::Base
    attr_reader :plan

    def initialize(plan:, subscribable: false)
      super
      @plan = plan
      @subscribable = subscribable
    end

    def formatted_price
      amount = plan.amount_cents / 100.0
      Kernel.format('%<amount>.2f %<currency>s', amount: amount, currency: plan.currency.upcase)
    end

    def interval_label
      plan.interval.humanize
    end

    def subscribable?
      @subscribable && plan.active?
    end
  end
end
