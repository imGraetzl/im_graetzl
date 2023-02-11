ActiveAdmin.register Favorite do
  menu parent: 'Users'
  actions :all, except: [:new, :edit, :destroy]

  scope :all, default: true
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :favoritable_type, include_blank: true, input_html: { class: 'admin-filter-select'}


  index { render 'index', context: self }

end
