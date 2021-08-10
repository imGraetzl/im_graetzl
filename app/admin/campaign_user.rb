ActiveAdmin.register CampaignUser do
  menu parent: 'Users', label: "Campaign User"

  index { render 'index', context: self }
  form partial: 'form'

  permit_params :campaign_title, :first_name, :last_name, :email, :zip, :city

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end

end
