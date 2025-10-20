# frozen_string_literal: true

module SubsEngine
  class GenerateInvoicePdf
    include Dry::Monads[:result]

    def call(invoice)
      @invoice = invoice

      Success(build_pdf.render)
    end

    private

    def build_pdf
      Prawn::Document.new(page_size: 'A4') do |pdf|
        render_header(pdf)
        render_line_items(pdf)
        render_totals(pdf)
        render_footer(pdf)
      end
    end

    def render_header(pdf)
      pdf.text 'INVOICE', size: 24, style: :bold
      pdf.move_down 10
      pdf.text "Invoice ##{@invoice.stripe_invoice_id}"
      pdf.text "Date: #{@invoice.created_at.to_date}"
      pdf.text "Status: #{@invoice.status.upcase}"
      pdf.move_down 20
    end

    def render_line_items(pdf)
      data = [%w[Description Qty Amount]]
      @invoice.line_items.each do |item|
        data << [item.description, item.quantity.to_s, format_amount(item.amount_cents, item.currency)]
      end

      pdf.table(data, header: true, width: pdf.bounds.width) do |t|
        t.row(0).font_style = :bold
        t.columns(1..2).align = :right
      end
    end

    def render_totals(pdf)
      pdf.move_down 10
      pdf.text "Total: #{format_amount(@invoice.amount_cents, @invoice.currency)}",
               size: 14, style: :bold, align: :right
    end

    def render_footer(pdf)
      pdf.move_down 30
      pdf.text 'Thank you for your business.', size: 10, color: '888888'
    end

    def format_amount(cents, currency)
      Kernel.format('%<amount>.2f %<currency>s', amount: cents / 100.0, currency: currency.upcase)
    end
  end
end
