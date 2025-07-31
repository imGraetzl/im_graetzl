ActiveAdmin.register CrowdDonationPledge do
  menu label: 'Material- & Zeitspenden', parent: 'Crowdfunding'
  includes :crowd_campaign, :user, :crowd_donation
  actions :all, except: [:new, :create, :destroy, :edit]

  config.sort_order = 'created_at_desc'

  scope :all, default: true
  scope :material
  scope :assistance
  scope :room

  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_campaign, collection: proc { CrowdCampaign.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

end
