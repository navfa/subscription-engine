# frozen_string_literal: true

class CreateSubsEngineUsageMetrics < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_usage_metrics, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :unit, null: false
      t.string :stripe_price_id
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :subs_engine_usage_metrics, :code, unique: true
    add_index :subs_engine_usage_metrics, :active
  end

  def down
    drop_table :subs_engine_usage_metrics
  end
end
