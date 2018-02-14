ActiveAdmin.register Graetzl do
  include ViewInApp
  menu priority: 2
  includes :users, :posts, :meetings, :locations

  filter :name

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :name, :slug, :area
end
