# frozen_string_literal: true

module SubsEngine
  class PlanRepository
    def find_active
      Plan.active.order(amount_cents: :asc)
    end

    def find_by_slug(slug)
      Plan.find_by(slug: slug)
    end

    def find_by_id(id)
      Plan.find_by(id: id)
    end
  end
end
