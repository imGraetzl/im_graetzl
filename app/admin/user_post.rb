ActiveAdmin.register UserPost do
  menu parent: 'Posts'

  filter :author, as: :select, collection: -> { User.all }
  filter :title
  filter :graetzl
  filter :content
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :title,
    :content,
    :graetzl_id,
    :author_id, :author_type,
    images_attributes: [:id, :file, :_destroy]
end
