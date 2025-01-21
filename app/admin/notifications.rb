ActiveAdmin.register Notification, as: "Notifications" do
  menu parent: 'Users'
  actions :all, except: [:new, :create, :edit, :destroy]

  scope :all
  scope 'Next Wien Mails', :next_wien, default: true
  scope 'Next Graz Mails', :next_graz
  scope 'Next Linz Mails', :next_linz
  scope 'Next Innsbruck Mails', :next_innsbruck
  scope 'Next Kärnten Mails',:next_kaernten
  scope 'Next Mühlviertel Mails',:next_muehlviertel

  filter :type, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :sent, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :seen, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  #filter :user_id, :as => :numeric
  filter :notify_at
  filter :notify_before
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }

  # action buttons
  action_item :delete_activity, only: :show do
    link_to "Aus Stream löschen", delete_activity_admin_notification_path(notifications), method: :put, data: { :confirm => 'Stream Activity wirklich löschen?' }
  end

  action_item :delete_all, only: :show do
    link_to "Alle E-Mail Notifications löschen (#{Notification.where(:subject_type => notifications.subject_type).
      where(:subject_id => notifications.subject_id).
      where(:child_type => notifications.child_type).
      where(:child_id => notifications.child_id).count})", delete_all_admin_notification_path(notifications), method: :put, data: { :confirm => 'E-Mail Notifications wirklich löschen?' }
  end

  action_item :delete_without_owner, only: :show do
    link_to "E-Mail Notifications (außer für Ersteller) löschen (#{Notification.where(:subject_type => notifications.subject_type).
      where(:subject_id => notifications.subject_id).
      where(:child_type => notifications.child_type).
      where(:child_id => notifications.child_id).count - 1})", delete_without_owner_admin_notification_path(notifications), method: :put, data: { :confirm => 'E-Mail Notifications wirklich löschen?' }
  end

  # member actions
  member_action :delete_activity, method: :put do
    Activity.where(:subject_type => resource.subject_type).
      where(:subject_id => resource.subject_id).
      where(:child_type => resource.child_type).
      where(:child_id => resource.child_id).delete_all
    flash[:success] = "Stream Activity gelöscht"
    redirect_to admin_notifications_path
  end

  member_action :delete_all, method: :put do
    notifications = Notification.where(:type => resource.type).
      where(:subject_type => resource.subject_type).
      where(:subject_id => resource.subject_id).
      where(:child_type => resource.child_type).
      where(:child_id => resource.child_id)
    notifications_count = notifications.count
    notifications.delete_all
    flash[:success] = "#{notifications_count} Notifications gelöscht"
    redirect_to admin_notifications_path
  end

  member_action :delete_without_owner, method: :put do
    Notification.where(:type => resource.type).
      where(:subject_type => resource.subject_type).
      where(:subject_id => resource.subject_id).
      where(:child_type => resource.child_type).
      where(:child_id => resource.child_id).each do |notification|
        next if notification.user.id == resource.subject.user.id
        notification.delete
    end
    flash[:success] = "Notifications (ausser für Ersteller) gelöscht"
    redirect_to admin_notifications_path
  end

end
