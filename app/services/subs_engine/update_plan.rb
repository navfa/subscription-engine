# frozen_string_literal: true

module SubsEngine
  class UpdatePlan
    include Dry::Monads[:result, :do]

    def call(plan, params)
      yield apply_changes(plan, params)
      Success(plan)
    end

    private

    def apply_changes(plan, params)
      if plan.update(params)
        Success(plan)
      else
        Failure[:validation_failed, plan]
      end
    end
  end
end
