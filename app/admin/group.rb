ActiveAdmin.register Group do
  include ViewInApp
  menu parent: 'Gruppe', priority: 1
  
  actions :index, :show, :edit, :update, :destroy

  show { render 'show', context: self }
  form partial: 'form'

  permit_params :title, :featured, group_users_attributes: [:id, :user_id, :role, :_destroy]
end
