# frozen_string_literal: true

class AddStripeSubscriptionItemIdToSubscriptions < ActiveRecord::Migration[8.0]
  def up
    add_column :subs_engine_subscriptions, :stripe_subscription_item_id, :string
  end

  def down
    remove_column :subs_engine_subscriptions, :stripe_subscription_item_id
  end
end
