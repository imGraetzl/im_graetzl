class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin_user!, only: [:admin, :admin_result, :notification_destroy]

  NOTIFICATIONS_PER_PAGE = 6

  def unseen_count
    # If disabled for performance
    # Rails.logger.info("[Request Unseen Count for User: #{current_user.id}]")
    # render json: { count: 0 }
    # current_user.new_website_notifications_count -> set to 0 in _user_menu
    # disable setInterval in navigation.js
    render json: { count: current_user.new_website_notifications_count }
  end

  def fetch
    @notifications = current_user.website_notifications.order("notifications.created_at DESC")
    @notifications.update_all(seen: true)
    @notifications = @notifications.page(params[:page]).per(NOTIFICATIONS_PER_PAGE)
  end

  def admin
    
  end

  def notification_destroy
    @notification = Notification.find(params[:id])
    @subject = @notification.subject
    
    notifications = Notification.where(
      type: @notification.type,
      subject_type: @notification.subject_type,
      subject_id: @notification.subject_id,
      child_type: @notification.child_type,
      child_id: @notification.child_id
    )

    notifications.delete_all

    respond_to do |format|
      format.js   # Ruft notification_destroy.js.erb auf
    end
  end

  def admin_result
    head :ok and return if browser.bot? && !request.format.js?

    # Nur Notification berücksichtigen welche in AdminTypes definiert sind
    admin_types = Notifications::AdminTypes.map(&:to_s)

    # Region-Parameter bereinigen: Bindestriche durch Unterstriche ersetzen
    region_scope = "next_#{(params.dig(:filter, :region) || 'wien').tr('-', '_')}"

    # Prüfen, ob der Scope existiert
    notifications = Notification.respond_to?(region_scope) ? Notification.send(region_scope) : Notification.none
    
    notifications = notifications
      .where(type: admin_types)
      .includes(:subject)
      .order(id: :desc)

    if params.dig(:filter, :type).present?
      type_classes = params.dig(:filter, :type)
      notifications = notifications.select { |n| type_classes.include?(n.subject_type) }
    end

    # Hierfür müsste ich graetzl_id in der notification setzen, evtl später ...
    #graetzl_ids = nil
    #if params.dig(:filter, :graetzl_ids)&.compact_blank.present?
    #  graetzl_ids = Graetzl.where(id: params[:filter][:graetzl_ids]).pluck(:id)
    #elsif params.dig(:filter, :district_ids)&.compact_blank.present?
    #  graetzl_ids = DistrictGraetzl.where(district_id: params[:filter][:district_ids]).distinct.pluck(:graetzl_id)
    #end
    #notifications = notifications.where(graetzl_id: graetzl_ids) if graetzl_ids.present?
    
    @notifications_count = notifications.count

    @notifications = notifications.map { |n| { notification: n, subject: n.subject } }
    @notifications = Kaminari.paginate_array(@notifications).page(params[:page]).per(params[:per_page] || 21)

  end

end
