ActiveAdmin.register CrowdBoostPledge do
  menu parent: 'Crowdfunding'
  includes :crowd_boost, :crowd_boost_slot
  actions :all, except: [:new, :create, :destroy, :edit]

  config.sort_order = 'created_at_desc'

  scope :all, default: true
  scope :authorized
  scope :debited
  scope :canceled

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_boost, collection: proc { CrowdBoost.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }

end
