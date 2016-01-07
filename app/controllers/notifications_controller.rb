class NotificationsController < ApplicationController
  before_action :authenticate_user!

  NOTIFICATIONS_PER_PAGE = 6

  def index
    @page = (params[:page] || '1').to_i
    scope = current_user.website_notifications.order("created_at DESC")
    @notifications = scope.page(@page).per(NOTIFICATIONS_PER_PAGE)
    @notifications.update_all(seen: true) if @page > 1
    @more_notifications = @page < @notifications.total_pages
  end

  def mark_as_seen
    ids = JSON.parse params[:ids]
    unless Notification.where(id: ids).update_all(seen: true)
      render json: {error: true}
    end
  end
end
