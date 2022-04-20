ActiveAdmin.register CrowdDonationPledge do
  menu parent: 'Crowdfunding'
  includes :crowd_campaign, :user, :crowd_donation
  actions :all, except: [:new, :create, :destroy, :edit]

  scope :all, default: true
  scope :material
  scope :assistance
  scope :room

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_campaign, collection: proc { CrowdCampaign.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

end
