ActiveAdmin.register CoopSuggestedTag do
  menu parent: 'Coop & Share'
  config.filters = false

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :name, :coop_demand_category_id

  # Within app/admin/resource_name.rb
  # Controller pagination overrides
  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end
end
