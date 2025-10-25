# frozen_string_literal: true

module SubsEngine
  class MrrChartComponent < ViewComponent::Base
    attr_reader :data

    def initialize(data:)
      super
      @data = data
    end

    def chart_data
      data.transform_values { |cents| cents / 100.0 }
    end
  end
end
