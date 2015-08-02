class NotificationsController < ApplicationController
  before_filter :authenticate_user!

  NOTIFICATIONS_PER_PAGE = 2

  def index
    page = params.permit(:page)[:page] || "1"
    @current_page = page.to_i
    scope = current_user.website_notifications.order("created_at DESC")
    total_count = scope.count
    offset = (@current_page - 1) * NOTIFICATIONS_PER_PAGE
    @notifications = scope.offset(offset).limit(NOTIFICATIONS_PER_PAGE)
    @more_notifications = NOTIFICATIONS_PER_PAGE * @current_page < total_count
  end
end
