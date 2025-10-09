# frozen_string_literal: true

module SubsEngine
  class PlanFormComponent < ViewComponent::Base
    attr_reader :plan

    def initialize(plan:)
      super
      @plan = plan
    end

    def intervals
      Plan.intervals.keys
    end

    def form_url
      plan.persisted? ? helpers.plan_path(plan) : helpers.plans_path
    end

    def form_method
      plan.persisted? ? :patch : :post
    end

    def submit_label
      plan.persisted? ? 'Update Plan' : 'Create Plan'
    end
  end
end
