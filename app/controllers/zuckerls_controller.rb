class ZuckerlsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @zuckerls = collection_scope.in(current_region).include_for_box
    @zuckerls = filter_collection(@zuckerls)
    @zuckerls = @zuckerls.page(params[:page]).per(15).reorder(Arel.sql("RANDOM()"))

  end

  def new
    @zuckerl = current_user.zuckerls.new
    @zuckerl.location = set_location_for_new
    @zuckerl.user = current_user
    @zuckerl.region_id = current_user.region_id
    @zuckerl.starts_at = Date.tomorrow + 1
    @zuckerl.ends_at = @zuckerl.starts_at + 1.month - 1.day
  end

  def create
    @zuckerl = current_user.zuckerls.new(zuckerl_params)
    @zuckerl.user = current_user
    @zuckerl.region_id = current_user.region_id
    @zuckerl.entire_region = true if entire_region?
    @zuckerl.amount = @zuckerl.total_price / 100

    if current_region.hot_august?
      @zuckerl.crowd_boost_id = current_region.default_crowd_boost_id
      @zuckerl.crowd_boost_charge_amount = @zuckerl.basic_price / 100
    end

    if @zuckerl.save
      @zuckerl.link ||= nil

      set_zuckerl_graetzls

      if valid_zuckerl_voucher_for(@zuckerl)
        redirect_to [:voucher, @zuckerl]
      else
        redirect_to [:address, @zuckerl]
      end
    else
      render :new
    end
  end

  def update
    set_zuckerl_or_redirect or return

    if params[:zuckerl][:subscription_id].present?
      @zuckerl.update zuckerl_voucher_params
      @zuckerl.pending!
      @zuckerl.update(amount: 0, payment_status: 'free', crowd_boost_id: nil, crowd_boost_charge_amount: nil)
      redirect_to [:summary, @zuckerl], notice: 'Dein Zuckerl-Guthaben wurde eingelöst'

    elsif params[:zuckerl][:user_zuckerl].present?

      @zuckerl.entire_region? ? current_user&.decrement!(:free_region_zuckerl) : current_user&.decrement!(:free_graetzl_zuckerl)
      @zuckerl.pending!
      @zuckerl.update(amount: 0, payment_status: 'free', crowd_boost_id: nil, crowd_boost_charge_amount: nil)
      redirect_to [:summary, @zuckerl], notice: 'Dein Zuckerl-Guthaben wurde eingelöst'

    elsif params[:edit_zuckerl].present?
      @zuckerl.update zuckerl_params_edit

      if @zuckerl.save
        set_zuckerl_graetzls
        redirect_to zuckerls_user_path, notice: 'Dein Zuckerl wurde aktualisiert'
      else
        render :edit
      end

    elsif @zuckerl.update zuckerl_address_params
      redirect_to [:choose_payment, @zuckerl]

    else
      render :edit
    end
  end

  def voucher
    @zuckerl = current_user.zuckerls.find(params[:id])
    @subscription = current_user.subscription
  end

  def address
    @zuckerl = current_user.zuckerls.find(params[:id])
    @zuckerl.assign_attributes(current_user_params)
  end

  def choose_payment
    @zuckerl = current_user.zuckerls.find(params[:id])
    redirect_to [:summary, @zuckerl] and return if !@zuckerl.incomplete?

    @setup_intent = ZuckerlService.new.create_setup_intent(@zuckerl)
  end

  def payment_authorized
    @zuckerl = current_user.zuckerls.find(params[:id])
    redirect_to [:choose_payment, @zuckerl] if params[:setup_intent].blank?

    success, error = ZuckerlService.new.payment_authorized(@zuckerl, params[:setup_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich autorisiert."
      redirect_to [:summary, @zuckerl]
    else
      flash[:error] = error
      redirect_to [:choose_payment, @zuckerl]
    end
  end

  def change_payment
    @zuckerl = current_user.zuckerls.find(params[:id])
    redirect_to zuckerls_user_path if !(@zuckerl.failed?)

    @payment_intent = ZuckerlService.new.create_retry_intent(@zuckerl)
  end

  def payment_changed
    @zuckerl = current_user.zuckerls.find(params[:id])
    redirect_to [:summary, @zuckerl] if params[:payment_intent].blank?

    success, error = ZuckerlService.new.payment_retried(@zuckerl, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich autorisiert."

      # Publish Immediate if Zuckerl is Payed and booked for now
      last_month = Date.today.last_month
      if @zuckerl.approved? && @zuckerl.starts_at <= Date.today && @zuckerl.ends_at >= Date.today
        ZuckerlService.new.publish(@zuckerl)
      end

      redirect_to [:summary, @zuckerl]
    else
      flash[:error] = error
      redirect_to [:change_payment, @zuckerl]
    end
  end

  def summary
    @zuckerl = current_user.zuckerls.find(params[:id])
  end

  def edit
    set_zuckerl_or_redirect
  end

  def destroy
    current_user.zuckerls.find(params[:id]).cancel!
    redirect_to zuckerls_user_path, notice: 'Dein Zuckerl wurde gelöscht'
  end

  private

  def has_graetzl_ids?
    params[:zuckerl].key?(:graetzl_ids) && params[:zuckerl][:graetzl_ids].present?
  end

  def has_district_ids?
    params[:zuckerl].key?(:district_ids) && params[:zuckerl][:district_ids].present?
  end

  def entire_region?
    if has_graetzl_ids?
      Array(params[:zuckerl][:graetzl_ids]).include?("entire_region")
    elsif has_district_ids?
      Array(params[:zuckerl][:district_ids]).include?("entire_region")
    else
      false
    end
  end

  def set_zuckerl_graetzls

    if has_graetzl_ids?

      if Array(params[:zuckerl][:graetzl_ids]).include?("entire_region")
        @zuckerl.update_column(:entire_region, true)
        @zuckerl.graetzl_ids = []
      else
        graetzl_ids = Array(params[:zuckerl][:graetzl_ids])
        @zuckerl.graetzl_ids = graetzl_ids
        @zuckerl.update_column(:entire_region, false)
      end

    elsif has_district_ids?

      if Array(params[:zuckerl][:district_ids]).include?("entire_region")
        @zuckerl.update_column(:entire_region, true)
        @zuckerl.graetzl_ids = []
      else
        district_ids = Array(params[:zuckerl][:district_ids])
        graetzl_ids = District.where(id: district_ids).joins(:graetzls).pluck('graetzls.id').uniq
        @zuckerl.graetzl_ids = graetzl_ids
        @zuckerl.update_column(:entire_region, false)
      end

    end
  end

  def collection_scope
    Zuckerl.live
  end

  def valid_zuckerl_voucher_for(zuckerl)
    zuckerl.user.valid_zuckerl_voucher_for(zuckerl) || zuckerl.user.subscription&.valid_zuckerl_voucher_for(zuckerl)
  end

  def set_location_for_new
    locations = current_user.locations.in(current_region).approved
    if params[:location_id].present?
      locations.find_by(id: params[:location_id])
    else
      locations.first
    end
  end

  def set_zuckerl_or_redirect
    @zuckerl = current_user.zuckerls.where(aasm_state: ['incomplete', 'pending']).find params[:id]
  rescue ActiveRecord::RecordNotFound
    redirect_to zuckerls_user_path, alert: 'Bereits freigeschaltene Zuckerl können nicht mehr bearbeitet werden.' and return
  end

  def filter_collection(collection)
    graetzl_ids = params.dig(:filter, :graetzl_ids)
    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      collection.in_area(favorite_ids)

    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      collection.in_area(graetzl_ids.reject(&:empty?))

    elsif params[:district_id].present?
      district = District.find(params[:district_id])
      collection.in_area(district.graetzl_ids)

    else
      collection
    end
  end

  def current_user_params
    {
      name: current_user.billing_address&.full_name || current_user.full_name,
      company: current_user.billing_address&.company,
      address: current_user.billing_address&.street || current_user.address_street,
      zip: current_user.billing_address&.zip || current_user.address_zip,
      city: current_user.billing_address&.city || current_user.address_city,
    }
  end

  def zuckerl_address_params
    params.require(:zuckerl).permit(
      :name,
      :company,
      :address,
      :zip,
      :city,
    )
  end

  def zuckerl_voucher_params
    params.require(:zuckerl).permit(
      :subscription_id,
    )
  end

  def zuckerl_params
    params.require(:zuckerl).permit(
      :title,
      :starts_at,
      :ends_at,
      :amount,
      :description,
      :cover_photo,
      :remove_cover_photo,
      :entire_region,
      :link,
      :location_id,
      graetzl_ids: [],
      district_ids: []
    )
  end

  def zuckerl_params_edit
    params.require(:zuckerl).permit(
      :title,
      :starts_at,
      :ends_at,
      :description,
      :cover_photo,
      :remove_cover_photo,
      :link,
      :location_id,
      graetzl_ids: [],
      district_ids: []
    )
  end
end
