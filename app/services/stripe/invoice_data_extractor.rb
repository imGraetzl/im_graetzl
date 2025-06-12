module Stripe
  class InvoiceDataExtractor
    def initialize(invoice_object)
      @invoice = invoice_object
    end

    def subscription_id
      @invoice.subscription ||
        @invoice.parent&.subscription_details&.subscription ||
        @invoice.lines&.data&.first&.parent&.subscription_item_details&.subscription
    end

    def period_start
      @invoice.lines&.data&.first&.period&.start
    end

    def period_end
      @invoice.lines&.data&.first&.period&.end
    end

    def amount_eur
      (@invoice.amount_remaining || @invoice.amount_due || 0).to_f / 100.0
    end
  end
end