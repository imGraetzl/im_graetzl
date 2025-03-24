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
  filter :user, collection: proc { User.registered.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
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
    column :status
    column :created_at
    column :debited_at
    column :total_price
    column :donation_amount
    column(:campaign_start) { |pledge| pledge&.crowd_campaign&.startdate }
    column(:campaign_end) { |pledge| pledge&.crowd_campaign&.enddate }
    column :crowd_campaign_id
    column(:campaign) { |pledge| pledge&.crowd_campaign&.title }
    #column(:category)  { |pledge| pledge&.crowd_campaign&.crowd_categories&.map(&:title)&.join(", ") }
    column(:first_name) { |pledge| pledge&.user&.first_name }
    column(:last_name) { |pledge| pledge&.user&.last_name }
    column :user_id
    column(:user_type) { |pledge| pledge&.user&.guest ? 'Guest User' : 'Registered User' }
    #column(:unique_person) { |pledge| Digest::SHA256.hexdigest(pledge&.user&.email) if pledge.user.present? }
    #column :guest_newsletter
    column :anonym
    column :region_id
  end

end
