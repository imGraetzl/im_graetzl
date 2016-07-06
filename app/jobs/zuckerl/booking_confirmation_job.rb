class Zuckerl::BookingConfirmationJob < ActiveJob::Base
  queue_as :default

  def perform(zuckerl)
    Rails.logger.info "BookingConfirmationJob start at: #{Time.now}"
    ActiveRecord::Base.connection_pool.with_connection do
      Zuckerl::BookingConfirmation.deliver zuckerl
    end
  end
end
