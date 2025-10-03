# frozen_string_literal: true

class CreateSubsEnginePlans < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_plans, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :interval, null: false, default: 0
      t.integer :amount_cents, null: false
      t.string :currency, null: false, limit: 3
      t.boolean :active, null: false, default: true
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :subs_engine_plans, :slug, unique: true
    add_index :subs_engine_plans, :active
  end

  def down
    drop_table :subs_engine_plans
  end
end
