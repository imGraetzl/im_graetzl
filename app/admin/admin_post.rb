ActiveAdmin.register AdminPost do
  menu parent: 'Posts'
  # actions :index, :show, :update, :edit, :destroy
  # includes :graetzl, :author
  #
  # filter :graetzl
  # filter :author_type
  # filter :title
  # filter :content
  # filter :created_at
  #
  # index { render 'index', context: self }
  # show { render 'show', context: self }
  form partial: 'form'

  permit_params :author_id,
    :author_type,
    :title,
    :content,
    graetzl_ids: [],
    district_ids: [],
    images_attributes: [
      :id,
      :file]
end
