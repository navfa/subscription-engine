# frozen_string_literal: true

module SubsEngine
  class DeactivatePlan
    include Dry::Monads[:result]

    def call(plan)
      return Failure(:already_inactive) unless plan.active?

      plan.update!(active: false)
      Success(plan)
    end
  end
end
