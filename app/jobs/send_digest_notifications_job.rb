class SendDigestNotificationsJob
  include SuckerPunch::Job

  def perform
    SuckerPunch.logger.info 'Perform DigestNotificationJob'
    ActiveRecord::Base.connection_pool.with_connection do
      User.find_each do |user|
        ::Notifications::DailyMail.new(user).deliver
      end
    end
  end
end
