ActiveAdmin.register CrowdPledge do
  menu parent: 'Crowdfunding'
  includes :crowd_campaign, :user, :crowd_reward
  actions :all, except: [:new, :create, :destroy, :edit]

  config.sort_order = 'created_at_desc'

  scope :all, default: true
  scope :incomplete
  scope :authorized
  scope :debited
  scope :failed
  scope :canceled

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_campaign, collection: proc { CrowdCampaign.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_reward, collection: proc { CrowdReward.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :contact_name
  filter :email
  filter :payment_method
  filter :stripe_customer_id
  filter :stripe_payment_intent_id
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

end
