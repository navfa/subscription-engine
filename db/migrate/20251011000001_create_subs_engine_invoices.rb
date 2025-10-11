# frozen_string_literal: true

class CreateSubsEngineInvoices < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_invoices, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :customer, null: false, type: :uuid, foreign_key: { to_table: :subs_engine_customers }
      t.references :subscription, null: true, type: :uuid, foreign_key: { to_table: :subs_engine_subscriptions }
      t.string :stripe_invoice_id
      t.integer :status, null: false, default: 0
      t.integer :amount_cents, null: false, default: 0
      t.string :currency, null: false, default: 'usd'
      t.datetime :period_start
      t.datetime :period_end
      t.datetime :paid_at
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :subs_engine_invoices, :stripe_invoice_id, unique: true
    add_index :subs_engine_invoices, [:customer_id, :status]
  end

  def down
    drop_table :subs_engine_invoices
  end
end
