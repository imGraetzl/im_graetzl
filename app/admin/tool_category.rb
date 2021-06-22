ActiveAdmin.register ToolCategory do
  menu parent: 'Toolteiler'

  index { render 'index', context: self }
  form partial: 'form'

  permit_params :name, :main_photo, :remove_main_photo, :position, :slug

end
