ActiveAdmin.register RoomCategory do
  menu parent: 'Raumteiler'

  config.filters = false
  
  index { render 'index', context: self }
  form partial: 'form'

  permit_params :name, :main_photo, :remove_main_photo, :position, :css_ico_class, :slug

end
