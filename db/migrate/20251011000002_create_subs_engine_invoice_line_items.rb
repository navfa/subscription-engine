# frozen_string_literal: true

class CreateSubsEngineInvoiceLineItems < ActiveRecord::Migration[8.0]
  def up
    create_table :subs_engine_invoice_line_items, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.references :invoice, null: false, type: :uuid, foreign_key: { to_table: :subs_engine_invoices }
      t.string :description, null: false
      t.integer :amount_cents, null: false, default: 0
      t.string :currency, null: false, default: 'usd'
      t.integer :quantity, null: false, default: 1
      t.integer :line_type, null: false, default: 0

      t.timestamps
    end
  end

  def down
    drop_table :subs_engine_invoice_line_items
  end
end
