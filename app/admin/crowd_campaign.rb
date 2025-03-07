ActiveAdmin.register CrowdCampaign do
  #include ViewInApp
  menu parent: 'Crowdfunding'

  includes :location, :user, :comments
  actions :all, except: [:new, :create]
  config.batch_actions = false

  scope :initialized, default: true
  scope :draft
  scope :re_draft
  scope :pending
  scope :approved
  scope :funding
  scope 'Payout Process', :payout
  scope :completed
  scope 'Paid', :payout_completed
  scope :declined
  #scope :all
  scope 'Newsletter', :guest_newsletter

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.registered.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_categories, input_html: { class: 'admin-filter-select'}
  filter :active_state, as: :select, collection: CrowdCampaign.active_states, input_html: { class: 'admin-filter-select'}
  filter :visibility_status, as: :select, collection: CrowdCampaign.visibility_statuses, input_html: { class: 'admin-filter-select'}
  filter :boost_status, as: :select, collection: CrowdCampaign.boost_statuses, input_html: { class: 'admin-filter-select'}
  filter :crowd_boost, collection: proc { CrowdBoost.order(:title).pluck(:title, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}

  filter :service_fee_percentage, :as => :numeric
  filter :title
  filter :startdate
  filter :enddate
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # action buttons

  action_item :draft, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Draft', draft_admin_crowd_campaign_path(crowd_campaign), { method: :put, data: { confirm: 'Kampagne auf Draft setzen | NutzerIn wird nicht darüber informiert.' } }
  end

  action_item :re_draft, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Re-Draft', re_draft_admin_crowd_campaign_path(crowd_campaign), { method: :put, data: { confirm: 'Kampagne auf Re-Draft setzen | NutzerIn wird darüber informiert.' } }
  end

  action_item :re_draft_without_mail, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Re-Draft (ohne Mail)', re_draft_without_mail_admin_crowd_campaign_path(crowd_campaign), { method: :put, data: { confirm: 'Kampagne auf Re-Draft setzen | NutzerIn wird nicht darüber informiert.' } }
  end

  action_item :decline, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Decline', decline_admin_crowd_campaign_path(crowd_campaign), { method: :put, data: { confirm: 'Kampagne auf Declined setzen | NutzerIn wird nicht darüber informiert.' } }
  end

  action_item :approve, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Freischalten', approve_admin_crowd_campaign_path(resource), method: :put, data: { confirm: 'Kampagne jetzt freischalten | NutzerIn wird darüber informiert.' }
  end

  action_item :payout, only: :show, if: proc{ crowd_campaign.payout_ready? && current_user.superadmin? } do
    link_to 'Kampagne auszahlen', payout_admin_crowd_campaign_path(resource), method: :put, data: { confirm: 'Kampagne jetzt auszahlen?' }
  end

  action_item :view_in_app, only: :show, priority: 20 do
    link_to 'App Vorschau', crowd_campaign_path(resource), target: '_blank'
  end

  # member actions
  member_action :approve, method: :put do
    if resource.approved!
      CrowdCampaignMailer.approved(resource).deliver_now
      flash[:success] = 'Crowdfunding Kampagne wurde freigeschalten.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht freigeschalten werden.'
      redirect_to resource_path
    end
  end

  member_action :decline, method: :put do
    if resource.declined!
      flash[:success] = 'Crowdfunding Kampagne wurde abgelenht.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht abgelenht werden.'
      redirect_to resource_path
    end
  end

  member_action :draft, method: :put do
    if resource.draft!
      flash[:success] = 'Crowdfunding Kampagne wurde auf Draft gesetzt.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht auf Draft gesetzt werden'
      redirect_to resource_path
    end
  end

  member_action :re_draft, method: :put do
    if resource.re_draft!
      CrowdCampaignMailer.re_draft(resource).deliver_now
      flash[:success] = 'Crowdfunding Kampagne wurde auf Überarbeitung gesetzt.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht auf Überarbeitung gesetzt werden'
      redirect_to resource_path
    end
  end

  member_action :re_draft_without_mail, method: :put do
    if resource.re_draft!
      flash[:success] = 'Crowdfunding Kampagne wurde auf Überarbeitung gesetzt.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht auf Überarbeitung gesetzt werden'
      redirect_to resource_path
    end
  end

  member_action :payout, method: :put do
    unless current_user.superadmin?
      flash[:error] = 'Keine Berechtigung für diese Aktion'
      redirect_to admin_crowd_campaigns_path
    else
      result = CrowdCampaignService.new.payout(resource)
      if result == :success
        flash[:notice] = 'Crowdfunding Kampagne wurde zur Auszahlung eingereicht.'
      else
        flash[:error] = 'Fehler beim Auszahlungsprozess. Bitte überprüfen ...'
      end
      redirect_to resource_path
    end
  end

  permit_params :active_state, :visibility_status, :status, :guest_newsletter, :title, :slogan, :description, :support_description, :aim_description, :about_description, :benefit, :benefit_description,
    :startdate, :enddate, :billable, :service_fee_percentage,
    :funding_1_amount, :funding_1_description, :funding_2_amount, :funding_2_description,
    :contact_company, :vat_id, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_instagram, :contact_facebook, :contact_email, :contact_phone,
    :location_id, :room_offer_id, :user_id,
    :graetzl_id, :address_street, :address_coords, :address_city, :address_zip, :address_description,
    :cover_photo, :remove_cover_photo, :video, :avatar, :remove_avatar,
    :crowd_boost_slot_id, :boost_status,
    crowd_category_ids: [],
    images_attributes: [:id, :file, :_destroy],
    crowd_rewards_attributes: [:id, :title, :description, :question, :limit],
    crowd_donations_attributes: [:id, :title, :description, :question]

  # Within app/admin/resource_name.rb
  # Controller pagination overrides

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
    column :id
    column :created_at
    column :startdate
    column :enddate
    column :status
    column :funding_status
    column :transaction_fee_percentage

    column('Minimalbetrag') { |i| number_to_currency(i.funding_1_amount, precision: 2 ,unit: "") }
    column('Optimalbetrag') { |i| number_to_currency(i.funding_2_amount, precision: 2 ,unit: "") }

    #column :effective_funding_sum
    column(:effective_funding_sum) { |i| number_to_currency(i.effective_funding_sum, precision: 2 ,unit: "") }
    #column :crowd_pledges_fee
    column(:crowd_pledges_fee) { |i| number_to_currency(i.crowd_pledges_fee, precision: 2 ,unit: "") }
    #column :crowd_pledges_fee_netto
    column(:crowd_pledges_fee_netto) { |i| number_to_currency(i.crowd_pledges_fee_netto, precision: 2 ,unit: "") }
    column :successful?
    column :region_id
  end

end
