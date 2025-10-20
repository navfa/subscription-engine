# frozen_string_literal: true

module SubsEngine
  class DeactivatePlan
    include Dry::Monads[:result]

    def call(plan)
      @plan = plan

      validate_active.bind do
        deactivate
      end
    end

    private

    def validate_active
      @plan.active? ? Success(@plan) : Failure[:already_inactive, @plan]
    end

    def deactivate
      @plan.update(active: false) ? Success(@plan) : Failure[:deactivation_failed, @plan]
    end
  end
end
