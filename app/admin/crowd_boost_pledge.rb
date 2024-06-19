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
    column :status
    column :debited_at
    column(:amount) { |pledge| ActionController::Base.helpers.number_with_precision(pledge.amount)}
    column :crowd_boost_id
    column(:crowd_boost) { |pledge| pledge.crowd_boost}
    column :region_id
    column :crowd_boost_slot_id
    column(:crowd_boost_slot) { |pledge| pledge.crowd_boost_slot}
    column :crowd_campaign_id
    column(:crowd_campaign) { |pledge| pledge.crowd_campaign}
  end

end
