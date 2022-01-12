ActiveAdmin.register RegionCall do
  menu parent: 'Regionen', label: "Call"

  index { render 'index', context: self }
  form partial: 'form'

  permit_params :region_type, :region_id, :name, :personal_position, :email, :phone, :gemeinden, :message

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end

end
