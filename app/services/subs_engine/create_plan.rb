# frozen_string_literal: true

module SubsEngine
  class CreatePlan
    include Dry::Monads[:result]

    def call(params)
      plan = Plan.new(params)
      persist(plan)
    end

    private

    def persist(plan)
      if plan.save
        Success(plan)
      else
        Failure(plan)
      end
    end
  end
end
