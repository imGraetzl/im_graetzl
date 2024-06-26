ActiveAdmin.register CrowdPledge do
  menu parent: 'Crowdfunding'
  includes :crowd_campaign, :user, :crowd_reward
  actions :all, except: [:new, :create, :destroy, :edit]

  config.sort_order = 'created_at_desc'

  scope :initialized, default: true
  scope :authorized
  scope :processing
  scope :debited
  scope :failed
  scope :refunded
  scope :canceled
  scope :incomplete
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_campaign, collection: proc { CrowdCampaign.scope_public.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_reward, collection: proc { CrowdReward.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :guest_newsletter, as: :select, include_blank: true, input_html: { class: 'admin-filter-select'}
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
  filter :inclomplete_reminder_sent_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

end
