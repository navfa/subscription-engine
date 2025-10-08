# frozen_string_literal: true

class AddStripePriceIdToPlans < ActiveRecord::Migration[8.0]
  def up
    add_column :subs_engine_plans, :stripe_price_id, :string
    add_index :subs_engine_plans, :stripe_price_id, unique: true
  end

  def down
    remove_column :subs_engine_plans, :stripe_price_id
  end
end
