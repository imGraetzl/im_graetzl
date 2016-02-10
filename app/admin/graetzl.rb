ActiveAdmin.register Graetzl do
  include ViewInApp
  menu priority: 2
  includes :users, :posts, :meetings, :locations

  scope :all, default: true
  scope :open
  scope :closed

  filter :name
  filter :state, as: :select, collection: Graetzl.states.keys
  filter :users
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :name, :state, :slug, :area
end
