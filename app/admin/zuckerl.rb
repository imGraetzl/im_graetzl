ActiveAdmin.register Zuckerl do
  menu parent: :users

  scope :initialized, default: true
  scope :pending
  scope :approved
  scope :live
  scope :debited
  scope :free
  scope :storno
  scope :cancelled
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :entire_region, input_html: { class: 'admin-filter-select'}
  filter :aasm_state, as: :select, collection: Zuckerl.aasm.states_for_select, input_html: { class: 'admin-filter-select'}
  filter :payment_status, as: :select, collection: Zuckerl.payment_statuses.keys, input_html: { class: 'admin-filter-select'}
  filter :payment_method, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :payment_wallet, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :stripe_payment_intent_id
  filter :invoice_number
  filter :title
  filter :description
  filter :created_at
  filter :debited_at
  filter :starts_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  batch_action :approve do |ids|
    batch_action_collection.find(ids).each do |zuckerl|
      ZuckerlService.new.approve(zuckerl)
    end
    redirect_to collection_path, alert: 'Die ausgewählten Zuckerl wurden freigeschalten.'
  end
  batch_action :live do |ids|
    batch_action_collection.find(ids).each do |zuckerl|
      zuckerl.live! if zuckerl.may_live?
    end
    redirect_to collection_path, alert: 'Die ausgewählten Zuckerl wurden live gestellt.'
  end
  batch_action :cancel do |ids|
    batch_action_collection.find(ids).each do |zuckerl|
      zuckerl.cancel!
    end
    redirect_to collection_path, alert: 'Die ausgewählten Zuckerl wurden als gelöscht markiert.'
  end
  batch_action :expire do |ids|
    batch_action_collection.find(ids).each do |zuckerl|
      zuckerl.expire! if zuckerl.may_expire?
    end
    redirect_to collection_path, alert: 'Die ausgewählten Zuckerl wurden als abgelaufen markiert.'
  end

  permit_params :location_id,
                :starts_at,
                :ends_at,
                :title,
                :description,
                :entire_region,
                :aasm_state,
                :active_admin_requested_event,
                :debited_at,
                :link,
                :cover_photo, :remove_cover_photo
  # Within app/admin/resource_name.rb
  # Controller pagination overrides
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
    #column :amount
    column(:amount) { |i| number_to_currency(i.amount, precision: 2 ,unit: "") }
    #column(:euro) { |zuckerl| number_to_currency(zuckerl.amount, precision: 2 ,unit: "€") }
    column :aasm_state
    column :payment_status
    column :debited_at
    column :entire_region
    column(:graetzl) { |zuckerl| zuckerl.graetzl if zuckerl.graetzl }
    column(:plz) { |zuckerl| zuckerl.graetzl&.zip if zuckerl.graetzl }
    column :region_id
    #column(:email) {|zuckerl| zuckerl.user.email if zuckerl.user }
  end

end
