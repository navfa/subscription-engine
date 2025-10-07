# frozen_string_literal: true

module SubsEngine
  module Matchable
    extend ActiveSupport::Concern

    private

    def match_result(result, &)
      Dry::Matcher::ResultMatcher.call(result, &)
    end
  end
end
