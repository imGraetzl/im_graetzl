class CrowdBoostsController < ApplicationController
  layout :set_layout
  before_action :authenticate_user!, except: [:show, :index, :charges, :campaigns, :call]

  def index
    if current_region
      @crowd_boosts = CrowdBoost.enabled.in(current_region)
    else
      @crowd_boosts = CrowdBoost.enabled.all
    end
  end

  def show
    @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
    region_id = current_region&.id

    # Use Special /leerstand URL in this Case
    leerstand_id = LEERSTAND_IDS[region_id]
    if leerstand_id && @crowd_boost.id == leerstand_id
      return redirect_to leerstand_path
    end
    
    @next_slot = @crowd_boost.next_slot(current_region)
    flash.now[:alert] = "Dieser Topf ist aktuell inaktiv." if @crowd_boost.disabled?
  end

  def leerstand
    region_id = current_region&.id
    leerstand_id = LEERSTAND_IDS[region_id]

    # show crowd_boost of region under /leerstand
    if leerstand_id
      @crowd_boost = CrowdBoost.find_by(id: leerstand_id)
      @next_slot = @crowd_boost.next_slot(current_region)

      case region_id
      when 'graz'
        render :call_graz
      else
        render :show
      end

    else

      if region_id
        redirect_to leerstand_url(host: welocally_platform_host)
      else
        # Build Special /leerstand page for welocally domain without region
        # render 'home/about'
        redirect_to about_platform_url(host: welocally_platform_host)
      end
      
    end
  end

  def call
    @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
    @next_slot = @crowd_boost.next_slot(current_region)
    if current_region.is?('graz')
      render 'call_graz'
    end
  end

  def charges
    @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
    @charges = @crowd_boost.crowd_boost_charges.debited_without_crowd_pledges.order(created_at: :desc)
  end

  def campaigns
    @crowd_boost = CrowdBoost.in(current_region).find(params[:id])
    @campaigns = @crowd_boost.crowd_campaigns.boost_initialized.by_currentness
  end

  private

  LEERSTAND_IDS = {
    'wien' => 1,
    'graz' => 2,
    'innsbruck' => 3
  }.freeze

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
