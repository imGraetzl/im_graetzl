ActiveAdmin.register LocationOwnership do
  menu parent: 'Locations'

  scope 'Alle', :all, default: true
  scope 'Pending', :all_pending
  scope :approved

  index do
    selectable_column
    column('ID', sortable: :id) do |ownership|
      link_to "##{ownership.id} ", admin_location_ownership_path(ownership)
    end
    column(:location) do |ownership|
      link_to ownership.location.name, admin_location_path(ownership.location)
    end
    column(:user) do |ownership|
      link_to ownership.user.username, admin_user_path(ownership.user_id)
    end
    column('Status') do |ownership|
      status_tag(ownership.state)
    end
    column('Letztes Update', :updated_at)
  end

  batch_action :approve do |ids|
    batch_action_collection.find(ids).each do |ownership|
      if ownership.may_approve?
        ownership.approve!
      end
    end
    redirect_to collection_path, alert: 'Die Anfragen wurden approved.'
  end


  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
