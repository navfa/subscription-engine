# frozen_string_literal: true

class EnablePgcrypto < ActiveRecord::Migration[8.0]
  def up
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end

  def down
    disable_extension 'pgcrypto'
  end
end
