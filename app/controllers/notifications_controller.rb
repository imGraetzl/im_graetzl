class NotificationsController < ApplicationController
  before_action :authenticate_user!

  NOTIFICATIONS_PER_PAGE = 2

  def index
    page = params.permit(:page)[:page] || "1"
    @current_page = page.to_i
    scope = current_user.website_notifications.order("created_at DESC")
    total_count = scope.count
    offset = (@current_page - 1) * NOTIFICATIONS_PER_PAGE
    @notifications = scope.offset(offset).limit(NOTIFICATIONS_PER_PAGE)
    Notification.where(user_id: current_user.id, id: @notifications.collect(&:id)).update_all(seen: true)
    @more_notifications = NOTIFICATIONS_PER_PAGE * @current_page < total_count
    @less_notifications = @current_page > 1
  end
end
