# frozen_string_literal: true

class DummyUser < ApplicationRecord
  self.table_name = 'dummy_users'
  include SubsEngine::Billable
end
