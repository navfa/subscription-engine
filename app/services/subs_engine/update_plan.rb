# frozen_string_literal: true

module SubsEngine
  class UpdatePlan
    include Dry::Monads[:result]

    def call(plan, params)
      @plan = plan
      @params = params

      apply_changes
    end

    private

    def apply_changes
      @plan.update(@params) ? Success(@plan) : Failure[:validation_failed, @plan]
    end
  end
end
