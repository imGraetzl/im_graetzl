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

  permit_params :status, :pledge_charge, :slug, :title, :slogan, :description, :avatar, :remove_avatar, :chargeable_status, :charge_description, :region_ids => []

  controller do
    def find_resource
      CrowdBoost.find(params[:id])
    end
    before_action do
      # Monkeypatch: temporär to_param für alle CrowdBoost-Instanzen im Admin
      CrowdBoost.class_eval do
        define_method(:to_param) do
          id.to_s
        end
      end
    end
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
    def apply_filtering(chain)
        super(chain).distinct
    end
  end

end
