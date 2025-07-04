ActiveAdmin.register ContactListEntry do
  menu parent: 'Einstellungen', label: "Contact List"

  remove_filter :user

  permit_params :name, :region_id, :email, :phone, :via_path, :message, :user_id

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end

  index { render 'index', context: self }

end
