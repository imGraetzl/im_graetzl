ActiveAdmin.register CrowdBoost do
  include ViewInApp
  menu parent: 'Crowdfunding'
  includes :crowd_campaigns
  actions :all

  scope :enabled, default: true
  scope :disabled

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  config.filters = false

  permit_params :status, :pledge_charge, :slug, :title, :slogan, :description, :avatar, :remove_avatar, :chargeable_status, :region_ids => []

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
