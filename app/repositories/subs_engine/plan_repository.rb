# frozen_string_literal: true

module SubsEngine
  class PlanRepository
    include Dry::Monads[:maybe]

    def find_active
      Plan.active.order(amount_cents: :asc)
    end

    def find_by_slug(slug)
      Maybe(Plan.find_by(slug: slug))
    end

    def find_by_id(id)
      Maybe(Plan.find_by(id: id))
    end
  end
end
