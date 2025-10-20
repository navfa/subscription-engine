# frozen_string_literal: true

module SubsEngine
  class CreatePlan
    include Dry::Monads[:result]

    def call(params)
      @plan = Plan.new(params)

      persist
    end

    private

    def persist
      @plan.save ? Success(@plan) : Failure[:validation_failed, @plan]
    end
  end
end
