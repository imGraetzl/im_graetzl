ActiveAdmin.register CrowdBoost do
  include ViewInApp
  menu parent: 'Crowdfunding'
  includes :crowd_campaigns
  actions :all

  scope :active, default: true
  scope :inactive

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :status, :slug, :title, :slogan, :description, :threshold_pledge_count, :threshold_funding_percentage, :boost_amount, :boost_precentage, :avatar, :remove_avatar

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
