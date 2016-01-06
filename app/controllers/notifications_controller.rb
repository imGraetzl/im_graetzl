class NotificationsController < ApplicationController
  before_action :authenticate_user!

  NOTIFICATIONS_PER_PAGE = 6

  def index
    page = params.permit(:page)[:page] || "1"
    @current_page = page.to_i
    scope = current_user.website_notifications.order("created_at DESC")
    total_count = scope.count
    offset = (@current_page - 1) * NOTIFICATIONS_PER_PAGE
    @notifications = scope.offset(offset).limit(NOTIFICATIONS_PER_PAGE)
    @more_notifications = NOTIFICATIONS_PER_PAGE * @current_page < total_count
    @less_notifications = @current_page > 1
  end

  def mark_as_seen
    ids = JSON.parse params[:ids]
    unless Notification.where(id: ids).update_all(seen: true)
      render json: {error: true}
    end
  end
end
