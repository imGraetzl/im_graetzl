class CrowdBoostsController < ApplicationController
  layout :set_layout
  before_action :authenticate_user!, except: [:show, :index, :charges, :campaigns, :submit_contact_list_entry, :leerstand]

  def index
    if current_region
      @crowd_boosts = CrowdBoost.enabled.in(current_region)
    else
      @crowd_boosts = CrowdBoost.enabled.all
    end
  end

  def show

    unless current_region
      @crowd_boost = CrowdBoost.find(params[:id])
      return if redirect_to_region?(@crowd_boost)
    else
      @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
    end
    
    region_id = current_region&.id

    # Use Special /leerstand URL in this Case
    leerstand_id = leerstand_ids[region_id]
    if leerstand_id && @crowd_boost.id == leerstand_id
      return redirect_to leerstand_path
    end
    
    @next_slot = @crowd_boost.next_slot(current_region) || @crowd_boost.prev_slot(current_region)
    @campaign_count = @crowd_boost.crowd_campaigns.boost_initialized.count
    @charge_count = @crowd_boost.crowd_boost_charges.debited_without_crowd_pledges.count

    flash.now[:alert] = "Dieser Topf ist aktuell inaktiv." if @crowd_boost.disabled?
  end

  def leerstand
    region_id = current_region&.id
    leerstand_id = leerstand_ids[region_id]

    # show crowd_boost of region under /leerstand
    if leerstand_id
      @crowd_boost = CrowdBoost.find_by(id: leerstand_id)
      @next_slot = @crowd_boost.next_slot(current_region) || @crowd_boost.prev_slot(current_region)
      @campaign_count = @crowd_boost.crowd_campaigns.boost_initialized.count
      @charge_count = @crowd_boost.crowd_boost_charges.debited_without_crowd_pledges.count

      flash.now[:alert] = "Einreichzeitraum beendet (#{@next_slot.timerange}) - Nächste Runde ist bereits in Vorbereitung." if @next_slot&.expired?

      case region_id
      when 'graz'
        @contact_list_entry = ContactListEntry.new
        render :call_graz
      when 'innsbruck'
        render :call_innsbruck
      when 'wien'
        render :call_wien
      else
        render :show
      end

    else

      if region_id
        redirect_to leerstand_url(host: welocally_platform_host), allow_other_host: true
      else
        # Build Special /leerstand page for welocally domain without region
        # render 'home/about'
        redirect_to about_platform_url(host: welocally_platform_host), allow_other_host: true
      end
      
    end
  end

  def charges
    @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
    @charges = @crowd_boost.crowd_boost_charges.includes(:user).debited_without_crowd_pledges.order(created_at: :desc)
  end

  def campaigns
    @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
    @campaigns = @crowd_boost.crowd_campaigns.boost_initialized.by_currentness
  end

  def submit_contact_list_entry
    region_id = current_region&.id
    leerstand_id = leerstand_ids[region_id]
    @crowd_boost = CrowdBoost.find_by(id: leerstand_id)
    @next_slot = @crowd_boost.next_slot(current_region) || @crowd_boost.prev_slot(current_region)
    @campaign_count = @crowd_boost.crowd_campaigns.boost_initialized.count
    @charge_count = @crowd_boost.crowd_boost_charges.debited_without_crowd_pledges.count

    @contact_list_entry = ContactListEntry.new(contact_list_entries_params)
    @contact_list_entry.region_id = current_region.id
    @contact_list_entry.via_path = request.path
    @contact_list_entry.user_id = current_user&.id
    if @contact_list_entry.save
      redirect_to params[:redirect_path], notice: "Vielen Dank für deine Einreichung! Wir melden uns in Kürze!"
      MarketingMailer.contact_list_entry(@contact_list_entry).deliver_later
      AdminMailer.new_contact_list_entry(@contact_list_entry).deliver_later
    else
      render params[:fallback_view]
    end
  end

  private

  def contact_list_entries_params
    params.require(:contact_list_entry).permit(
      :region_id,
      :name,
      :email,
      :message
    )
  end

  def leerstand_ids
    @leerstand_ids ||= Region.all.each_with_object({}) do |region, hash|
      id = region.default_crowd_boost_id
      hash[region.id] = id if id.present?
    end
  end

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

  def welocally_platform_host
    if Rails.env.production?
      "www.#{Rails.application.config.welocally_host}"
    else
      Rails.application.config.welocally_host
    end
  end

end
