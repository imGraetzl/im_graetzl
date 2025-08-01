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
  scope :paid_out
  scope :storno
  scope :all

  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :rental_status, as: :select, collection: RoomRental.rental_statuses, input_html: { class: 'admin-filter-select'}
  filter :payment_status, as: :select, collection: RoomRental.payment_statuses.keys, input_html: { class: 'admin-filter-select'}
  filter :room_offer, collection: proc { RoomOffer.order(:slogan).pluck(:slogan, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
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
