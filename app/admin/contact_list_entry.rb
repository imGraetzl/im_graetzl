ActiveAdmin.register ContactListEntry do
  menu parent: 'Einstellungen', label: "Contact List"

  permit_params :name, :region_id, :email, :phone, :via_path

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end

end
