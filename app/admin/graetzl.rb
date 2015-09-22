ActiveAdmin.register Graetzl do
  menu priority: 2

  # scopes
  scope :all, default: true
  scope :open
  scope :closed

  # index
  index do
    render 'index', context: self
  end

  # filter
  filter :name
  filter :state, as: :select, collection: Graetzl.states.keys
  filter :users
  filter :created_at
  filter :updated_at

  # show
  show do
    render 'show', context: self
  end

  # form
  form partial: 'form'

  # strong params
  permit_params :name, :state, :slug, :area
end
