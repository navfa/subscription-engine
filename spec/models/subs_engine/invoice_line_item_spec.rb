# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubsEngine::InvoiceLineItem do
  describe 'validations' do
    it 'requires description' do
      item = build(:invoice_line_item, description: nil)

      expect(item).not_to be_valid
    end

    it 'requires positive quantity' do
      item = build(:invoice_line_item, quantity: 0)

      expect(item).not_to be_valid
    end
  end

  describe 'enums' do
    it 'supports subscription type' do
      item = build(:invoice_line_item, line_type: :subscription)

      expect(item).to be_subscription
    end

    it 'supports proration type' do
      item = build(:invoice_line_item, line_type: :proration)

      expect(item).to be_proration
    end
  end
end
