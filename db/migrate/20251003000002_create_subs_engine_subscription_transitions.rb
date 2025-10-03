# frozen_string_literal: true

class CreateSubsEngineSubscriptionTransitions < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_subscription_transitions, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :to_state, null: false
      t.integer :sort_key, null: false
      t.references :subscription, null: false, type: :uuid,
                                  foreign_key: { to_table: :subs_engine_subscriptions }
      t.boolean :most_recent, null: false, default: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps null: false
    end

    add_index :subs_engine_subscription_transitions,
              [:subscription_id, :sort_key],
              unique: true,
              name: 'idx_subs_engine_sub_transitions_sort_key'

    add_index :subs_engine_subscription_transitions,
              [:subscription_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: 'idx_subs_engine_sub_transitions_most_recent'
  end

  def down
    drop_table :subs_engine_subscription_transitions
  end
end
