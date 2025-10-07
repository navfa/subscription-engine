# frozen_string_literal: true

module SubsEngine
  class UpdatePlan
    include Dry::Monads[:result]

    def call(plan, params)
      if plan.update(params)
        Success(plan)
      else
        Failure(plan)
      end
    end
  end
end
