class SendDigestNotificationsJob
  include SuckerPunch::Job

  def perform
    SuckerPunch.logger.info "DigestNotificationJob start at: #{Time.now}"
    ActiveRecord::Base.connection_pool.with_connection do
      User.find_each do |user|
        ::Notifications::DailyMail.new(user).deliver
      end
    end
  end
end
