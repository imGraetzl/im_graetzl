class Zuckerl::InvoiceJob < ActiveJob::Base
  queue_as :default

  def perform(zuckerl)
    Rails.logger.info "InvoiceJob start at: #{Time.now}"
    ActiveRecord::Base.connection_pool.with_connection do
      Zuckerl::Invoice.deliver zuckerl
    end
  end
end
