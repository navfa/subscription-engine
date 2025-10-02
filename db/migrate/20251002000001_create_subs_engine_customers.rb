# frozen_string_literal: true

class CreateSubsEngineCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :subs_engine_customers, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :external_id, null: false
      t.string :email, null: false
      t.string :stripe_customer_id
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :subs_engine_customers, :external_id, unique: true
    add_index :subs_engine_customers, :stripe_customer_id, unique: true
    add_index :subs_engine_customers, :email
  end
end
