ActiveAdmin.register District do
  include ViewInApp
  menu label: 'Bezirke', parent: 'Einstellungen'
  includes :graetzls
  actions :all, except: [:new, :create, :destroy]

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :zip
  filter :name

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'


  permit_params :name, :area
end
