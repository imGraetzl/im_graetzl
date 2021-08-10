ActiveAdmin.register GroupCategory do
  menu parent: 'Groups'

  permit_params :title
end
