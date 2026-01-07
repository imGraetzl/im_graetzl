ActiveAdmin.register RoomBooster do
  menu parent: 'Raumteiler'
  includes :room_offer, :user
  actions :all, except: [:new, :create, :destroy]

  scope :initialized, default: true
  scope :pending
  scope :active
  scope :expired
  scope :storno
  scope :incomplete
  scope :free
  scope :all

  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_status, as: :select, collection: RoomBooster.payment_statuses.keys, input_html: { class: 'admin-filter-select'}
  filter :room_offer, collection: proc { RoomOffer.order(:slogan).pluck(:slogan, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_method, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_wallet, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :stripe_payment_intent_id
  filter :invoice_number
  filter :debited_at
  filter :created_at
  filter :updated_at


  index { render 'index', context: self }
  form partial: 'form'

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
    def apply_filtering(chain)
        super(chain).distinct
    end
  end

  csv do
    column :id
    column :created_at
    column :starts_at_date
    #column(:email) {|booster| booster.user.email if booster.user }
    column :status
    column :payment_status
    #column :amount
    column(:amount) { |i| number_to_currency(i.amount, precision: 2 ,unit: "") }
    column :region_id
  end

  permit_params :starts_at_date

end
