ActiveAdmin.register EnergyCategory do
  menu parent: 'Energieteiler'
  config.filters = false
  
  index { render 'index', context: self }
  form partial: 'form'

  permit_params :title,
    :label,
    :group,
    :main_photo,
    :remove_main_photo,
    :position,
    :css_ico_class,
    :slug,
    :hidden

end
