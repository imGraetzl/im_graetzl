ActiveAdmin.register RoomRental do
  menu parent: 'Raumteiler'
  includes :room_offer, :user
  actions :all, except: [:new, :create, :destroy]

  scope :initialized, default: true
  scope :pending
  scope :approved
  scope :canceled
  scope :rejected
  scope :expired
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :rental_status, as: :select, collection: RoomRental.rental_statuses.keys
  filter :payment_status, as: :select, collection: RoomRental.payment_statuses.keys
  filter :room_offer, collection: proc { RoomOffer.order(:slogan).pluck(:slogan, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_method
  filter :stripe_customer_id
  filter :stripe_payment_intent_id
  filter :debited_at
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :rental_status

end
