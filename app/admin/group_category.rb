ActiveAdmin.register GroupCategory do
  menu parent: 'Einstellungen'
  config.filters = false
  
  permit_params :title
end
