class Zuckerl::BookingConfirmationJob < ActiveJob::Base
  queue_as :default

  def perform(zuckerl)
    Rails.logger.info "BookingConfirmationJob start at: #{Time.now}"
    ActiveRecord::Base.connection_pool.with_connection do
      mandrill_mail = Zuckerl::BookingConfirmationMail.new zuckerl
      mandrill_mail.deliver
    end
  end
end
