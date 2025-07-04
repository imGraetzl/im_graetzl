ActiveAdmin.register CrowdBoostCharge do
  menu parent: 'Crowdfunding'
  includes :crowd_boost, :user
  actions :all, except: [:new, :create, :destroy, :edit]

  config.sort_order = 'created_at_desc'

  scope :initialized, default: true
  scope :authorized
  scope :processing
  scope :debited
  scope :failed
  scope :refunded
  scope :incomplete
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :charge_type, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_boost, collection: proc { CrowdBoost.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :payment_method, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_wallet, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :id, :as => :numeric
  filter :contact_name
  filter :email
  filter :stripe_customer_id
  filter :stripe_payment_intent_id
  filter :debited_at
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # Within app/admin/resource_name.rb
  # Controller pagination overrides
  controller do
    def apply_pagination(chain)
        chain = super unless formats.include?(:json) || formats.include?(:csv)
        chain
    end
  end

  csv do
    column :id
    column :payment_status
    column :debited_at
    column(:amount) { |charge| ActionController::Base.helpers.number_with_precision(charge.amount)}
    column :crowd_boost_id
    column(:crowd_boost) { |charge| charge.crowd_boost}
    column :region_id
    column :user_id
    column :contact_name
    column :email
    column :charge_type
    column :zuckerl_id
    column :room_booster_id
    column :crowd_pledge_id
  end

end
