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

    # Filtern nach graetzl_id über die Subjects
    if params.dig(:filter, :graetzl_ids)&.compact_blank.present?
      graetzl_ids = Graetzl.where(id: params[:filter][:graetzl_ids]).pluck(:id)
      notifications = notifications.select do |n|
        subject = n.subject
        next true if subject.respond_to?(:entire_region) && subject.entire_region
        next true if subject.respond_to?(:newsletter_status) && ([subject.newsletter_status].flatten & ["region", "platform"]).any?
        next false unless subject.present? && (subject.respond_to?(:graetzl_id) || subject.respond_to?(:graetzl) || subject.respond_to?(:graetzls))

        if subject.respond_to?(:graetzl_id)
          graetzl_ids.include?(subject.graetzl_id)
        elsif subject.respond_to?(:graetzl) && subject.graetzl.respond_to?(:id)
          graetzl_ids.include?(subject.graetzl.id)
        elsif subject.respond_to?(:graetzls) && subject.graetzls.respond_to?(:pluck)
          (subject.graetzls.pluck(:id) & graetzl_ids).any?
        else
          false
        end
      end
    end
    
    # 1. Duplikate entfernen (wie in notification_destroy)
    distinct_notifications = notifications.uniq { |n| [n.subject_type, n.subject_id, n.type, n.child_type, n.child_id] }

    # 2. Count basiert auf deduplizierten Notifications
    @notifications_count = distinct_notifications.size

    # 3. Pagination + direkte Übergabe an View
    @notifications = Kaminari.paginate_array(distinct_notifications)
      .page(params[:page])
      .per(params[:per_page] || 21)

  end

end
