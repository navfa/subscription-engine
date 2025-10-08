# frozen_string_literal: true

module SubsEngine
  class DeactivatePlan
    include Dry::Monads[:result, :do]

    def call(plan)
      yield validate_active(plan)
      yield deactivate(plan)
      Success(plan)
    end

    private

    def validate_active(plan)
      plan.active? ? Success(plan) : Failure[:already_inactive, plan]
    end

    def deactivate(plan)
      if plan.update(active: false)
        Success(plan)
      else
        Failure[:deactivation_failed, plan]
      end
    end
  end
end
