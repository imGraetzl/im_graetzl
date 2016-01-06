class NotificationsController < ApplicationController
  before_action :authenticate_user!

  NOTIFICATIONS_PER_PAGE = 6

  def index
    @page = (params[:page] || '1').to_i
    scope = current_user.website_notifications.order("created_at DESC")
    #total_count = scope.count
    #offset = (@current_page - 1) * NOTIFICATIONS_PER_PAGE
    #@notifications = scope.offset(offset).limit(NOTIFICATIONS_PER_PAGE)
    @notifications = scope.page(@page).per(NOTIFICATIONS_PER_PAGE)
    @notifications.update_all(seen: true) if @page > 1
    @more_notifications = @notifications.count < @notifications.total_count
    #@less_notifications = @current_page > 1
  end

  def mark_as_seen
    ids = JSON.parse params[:ids]
    unless Notification.where(id: ids).update_all(seen: true)
      render json: {error: true}
    end
  end

  def paginate
      # automatically mark all as seen
      # update counter as well...
  end
end
