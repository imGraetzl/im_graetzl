ActiveAdmin.register ApiAccount do
  menu parent: 'Einstellungen'

  config.filters = false

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'


  permit_params :name, :api_key, :enabled, :region_id
end
