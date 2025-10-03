# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Schema.define do
      unless table_exists?(:dummy_users)
        create_table :dummy_users, id: :uuid, default: 'gen_random_uuid()' do |t|
          t.string :email
          t.timestamps
        end
      end
    end
  end
end
