ActiveAdmin.register ToolRental do
  menu parent: 'Geräteteiler'
  includes :tool_offer, :user
  actions :all, except: [:new, :create, :destroy]

  scope :initialized, default: true
  scope :pending
  scope :approved
  scope :return_pending
  scope :return_confirmed
  scope :canceled
  scope :rejected
  scope :expired
  scope :paid_out
  scope :storno
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :rental_status, as: :select, collection: ToolRental.rental_statuses, input_html: { class: 'admin-filter-select'}
  filter :payment_status, as: :select, collection: ToolRental.payment_statuses.keys, input_html: { class: 'admin-filter-select'}
  filter :tool_offer, collection: proc { ToolOffer.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.registered.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_method, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_wallet, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :stripe_payment_intent_id
  filter :invoice_number
  filter :debited_at
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :rental_status

end
