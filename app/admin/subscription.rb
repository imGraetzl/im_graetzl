ActiveAdmin.register Subscription do
  menu label: "Abos", priority: 3

  actions :all, except: [:destroy, :edit]

  scope :initialized, default: true
  scope :active
  scope :canceled
  scope :past_due
  scope :coupon
  scope :all

  #filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  #filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  #filter :subscription_plan, include_blank: true, input_html: { class: 'admin-filter-select'}

  index { render 'index', context: self }

end
