# frozen_string_literal: true

module SubsEngine
  class CreatePlan
    include Dry::Monads[:result, :do]

    def call(params)
      plan = Plan.new(params)
      yield persist(plan)
      Success(plan)
    end

    private

    def persist(plan)
      if plan.save
        Success(plan)
      else
        Failure[:validation_failed, plan]
      end
    end
  end
end
