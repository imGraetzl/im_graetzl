ActiveAdmin.register Zuckerl do
  menu parent: :locations

  scope :initialized, default: true
  scope :pending
  scope :approved
  scope :cancelled
  scope :live
  scope "#{I18n.localize Time.now.end_of_month+1.day, format: '%B'} Zuckerl", :next_month_live
  scope :expired
  scope "Bezahlt", :marked_as_paid
  scope :free
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :title
  filter :description
  filter :entire_region
  filter :aasm_state, as: :select, collection: Zuckerl.aasm.states_for_select
  filter :payment_status, as: :select, collection: Zuckerl.payment_statuses.keys
  filter :payment_method
  filter :stripe_customer_id
  filter :stripe_payment_intent_id
  filter :created_at
  filter :debited_at

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
    column(:email) {|zuckerl| zuckerl.user.email if zuckerl.user }
    column :amount
    column :debited_at
    column :payment_status
    column :aasm_state
    column :entire_region
    column(:graetzl) { |zuckerl| zuckerl.graetzl if zuckerl.graetzl }
    column(:plz) { |zuckerl| zuckerl.graetzl&.zip if zuckerl.graetzl }
    column :region_id
  end

end
