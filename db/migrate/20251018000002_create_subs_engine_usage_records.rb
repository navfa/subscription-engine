# frozen_string_literal: true

class CreateSubsEngineUsageRecords < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_usage_records, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :customer, null: false, type: :uuid, foreign_key: { to_table: :subs_engine_customers }
      t.references :usage_metric, null: false, type: :uuid, foreign_key: { to_table: :subs_engine_usage_metrics }
      t.integer :quantity, null: false
      t.datetime :recorded_at, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :subs_engine_usage_records, [:customer_id, :usage_metric_id, :recorded_at],
              name: 'idx_usage_records_customer_metric_time'
  end

  def down
    drop_table :subs_engine_usage_records
  end
end
