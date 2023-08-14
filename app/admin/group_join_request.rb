ActiveAdmin.register GroupJoinRequest do
  menu parent: 'Einstellungen'
  
  actions :index, :show, :destroy

  includes :user

  scope :all, default: true
  scope :pending
  scope :accepted
  scope :rejected

  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :group, collection: proc { Group.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}

  index { render 'index', context: self }
  show { render 'show', context: self }

  # action buttons
  action_item :accept, only: :show, if: proc{ group_join_request.pending? } do
    link_to 'Beitritt akzeptieren', accept_admin_group_join_request_path(group_join_request), { method: :put }
  end

  action_item :reject, only: :show, if: proc{ group_join_request.pending? } do
    link_to 'Beitritt ablehnen', reject_admin_group_join_request_path(group_join_request), { method: :put }
  end

  # member actions
  member_action :accept, method: :put do
    if !resource.group.users.include?(resource.user)
      resource.group.group_users.create(user: resource.user)
      if resource.group.save
        GroupMailer.join_request_accepted(resource.group, resource.user).deliver_later
      end
    end
    resource.assign_attributes(status: :accepted)
    resource.save
    flash[:success] = 'Beitritt genehmigt'
    redirect_to admin_group_join_requests_path
  end

  member_action :reject, method: :put do
    resource.assign_attributes(status: :rejected)
    resource.save
    flash[:error] = 'Beitritt abgelehnt'
    redirect_to admin_group_join_requests_path
  end

  permit_params :group_id, :status
end
