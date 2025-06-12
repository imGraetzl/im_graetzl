module Stripe
  class InvoiceDataExtractor
    def initialize(invoice_object)
      @invoice = invoice_object
    end

    def subscription_id
      @invoice[:subscription] ||
      @invoice.dig(:parent, :subscription_details, :subscription) ||
      @invoice.dig(:lines, :data, 0, :parent, :subscription_item_details, :subscription)
    end

    def period_start
      @invoice.dig(:lines, :data, 0, :period, :start)
    end

    def period_end
      @invoice.dig(:lines, :data, 0, :period, :end)
    end

    def amount_eur
      (@invoice[:amount_remaining] || @invoice[:amount_due] || 0) / 100.0
    end
  end
end