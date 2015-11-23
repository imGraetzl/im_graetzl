ActiveAdmin.register Post do
  actions :index, :show, :update, :edit

  # index
  index do
    render 'index', context: self
  end

  # filter
  filter :graetzl
  filter :author_type
  filter :title
  filter :content
  filter :created_at

  # show
  show do
    render 'show', context: self
  end

  # form
  form partial: 'form'

  # strong parameters (maybe something missing)
  permit_params :graetzl_id,
    :author_id,
    :author_type,
    :title,
    :content,
    images_attributes: [
      :id,
      :file]
end
