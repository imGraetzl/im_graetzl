ActiveAdmin.register Curator do
  # index
  index do
    render 'index', context: self
  end

  # filter
  filter :user
  filter :graetzl
  filter :website
  filter :description

  # show
  show do
    render 'show', context: self
  end

  # form
  form partial: 'form'

  # strong params
  permit_params :graetzl_id, :user_id, :website, :description
end
