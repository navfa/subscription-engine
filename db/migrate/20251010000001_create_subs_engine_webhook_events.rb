# frozen_string_literal: true

class CreateSubsEngineWebhookEvents < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_webhook_events, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :stripe_event_id, null: false
      t.string :event_type, null: false
      t.integer :status, null: false, default: 0
      t.jsonb :payload, null: false, default: {}
      t.text :error_message

      t.timestamps
    end

    add_index :subs_engine_webhook_events, :stripe_event_id, unique: true
    add_index :subs_engine_webhook_events, :event_type
    add_index :subs_engine_webhook_events, :status
  end

  def down
    drop_table :subs_engine_webhook_events
  end
end
