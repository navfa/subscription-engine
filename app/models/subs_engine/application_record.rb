# frozen_string_literal: true

module SubsEngine
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
