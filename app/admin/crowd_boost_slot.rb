ActiveAdmin.register CrowdBoostSlot do
  menu parent: 'Crowdfunding'
  includes :crowd_campaigns
  includes :crowd_boost_pledges

  actions :all

  scope :all, default: true
  scope :active
  scope :upcoming
  scope :expired

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :amount_limit, :max_campaigns, :starts_at, :ends_at, :crowd_boost_id, graetzl_ids: []

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
    def apply_filtering(chain)
        super(chain).distinct
    end
  end

end
