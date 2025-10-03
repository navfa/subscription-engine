# frozen_string_literal: true

class CreateSubsEngineSubscriptions < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_subscriptions, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :customer, null: false, type: :uuid, foreign_key: { to_table: :subs_engine_customers }
      t.references :plan, null: false, type: :uuid, foreign_key: { to_table: :subs_engine_plans }
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.datetime :trial_end
      t.datetime :canceled_at
      t.string :stripe_subscription_id
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :subs_engine_subscriptions, :stripe_subscription_id, unique: true
    add_index :subs_engine_subscriptions, [:customer_id, :plan_id]
  end

  def down
    drop_table :subs_engine_subscriptions
  end
end
