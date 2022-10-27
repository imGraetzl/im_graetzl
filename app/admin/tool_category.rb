ActiveAdmin.register ToolCategory do
  menu parent: 'Geräteteiler'

  index { render 'index', context: self }
  form partial: 'form'

  permit_params :name, :icon, :main_photo, :remove_main_photo, :position, :slug

end
