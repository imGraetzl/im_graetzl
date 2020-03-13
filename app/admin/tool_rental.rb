ActiveAdmin.register ToolRental do
  menu parent: 'Toolteiler'
  includes :tool_offer, :user
  actions :all, except: [:new, :create, :destroy]

  scope :all, default: true
  scope :pending
  scope :approved
  scope :return_pending
  scope :return_confirmed
  scope :canceled
  scope :rejected
  scope :expired

  filter :rental_status, as: :select, collection: ToolRental.rental_statuses.keys
  filter :payment_status, as: :select, collection: ToolRental.payment_statuses.keys
  filter :tool_offer, collection: proc { ToolOffer.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :rental_status, :payment_status

end
