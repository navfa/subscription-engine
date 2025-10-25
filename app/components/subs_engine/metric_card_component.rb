# frozen_string_literal: true

module SubsEngine
  class MetricCardComponent < ViewComponent::Base
    attr_reader :label, :value, :style

    def initialize(label:, value:, style: :default)
      super
      @label = label
      @value = value
      @style = style
    end

    def value_class
      case style
      when :positive then 'subs-engine-card__value subs-engine-card__value--positive'
      when :negative then 'subs-engine-card__value subs-engine-card__value--negative'
      else 'subs-engine-card__value'
      end
    end
  end
end
