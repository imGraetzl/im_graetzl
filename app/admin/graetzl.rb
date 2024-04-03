ActiveAdmin.register Graetzl do
  include ViewInApp
  menu parent: 'Einstellungen'
  includes :districts
  actions :all, except: [:destroy]

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :name
  filter :users_count

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # Within app/admin/resource_name.rb
  # Controller pagination overrides
  controller do
      def apply_pagination(chain)
          chain = super unless formats.include?(:json) || formats.include?(:csv)
          chain
      end
  end

  permit_params :name, :slug, :zip, :region_id, :neighborless, neighbour_ids: []
end
