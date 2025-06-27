ActiveAdmin.register CrowdBoostSlot do
  menu parent: 'Crowdfunding'
  includes :crowd_campaigns
  includes :crowd_boost_pledges

  actions :all

  scope :all, default: true
  scope :currently_open
  scope :active
  scope :expired

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  remove_filter :crowd_boost_pledges
  remove_filter :crowd_boost_slot_graetzls
  remove_filter :graetzls


  permit_params :slot_amount_limit, :starts_at, :ends_at, :crowd_boost_id, :threshold_pledge_count, :threshold_funding_percentage, :boost_amount, :boost_percentage, :boost_amount_limit, :slot_description, :slot_process_description, :slot_detail_description, :slot_terms, graetzl_ids: []

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
