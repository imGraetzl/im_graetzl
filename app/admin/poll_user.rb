ActiveAdmin.register PollUser do
  menu parent: 'Energieteiler'
  actions :all, except: [:new, :edit]

  scope :all, default: true
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :poll, collection: proc { Poll.all }, include_blank: true, input_html: { class: 'admin-filter-select'}

  index { render 'index', context: self }
  show { render 'show', context: self }

end
