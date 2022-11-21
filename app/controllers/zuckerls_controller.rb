class ZuckerlsController < ApplicationController
  before_action :authenticate_user!, except: [:index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @zuckerls = collection_scope.in(current_region).include_for_box
    @zuckerls = filter_collection(@zuckerls)
    @zuckerls = @zuckerls.page(params[:page]).per(15).order(Arel.sql("RANDOM()"))

  end

  def new
    set_location_for_new or return
    @zuckerl = @location.zuckerls.new
  end

  def create
    @location = current_user.locations.find(params[:location_id])
    @zuckerl = @location.zuckerls.new(zuckerl_params)
    @zuckerl.user = current_user
    @zuckerl.region_id = @location.region_id
    @zuckerl.amount = @zuckerl.total_price / 100

    if @zuckerl.save
      @zuckerl.link ||= nil
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
    set_location
    set_zuckerl_or_redirect or return

    if params[:zuckerl][:subscription_id].present?
      @zuckerl.update zuckerl_voucher_params
      @zuckerl.pending!
      @zuckerl.update(amount: 0, payment_status: 'free',)
      redirect_to [:summary, @zuckerl], notice: 'Dein Zuckerl-Guthaben wurde eingelöst'

    elsif params[:zuckerl][:user_zuckerl].present?

      @zuckerl.entire_region? ? current_user&.decrement!(:free_region_zuckerl) : current_user&.decrement!(:free_graetzl_zuckerl)
      @zuckerl.pending!
      @zuckerl.update(amount: 0, payment_status: 'free',)
      redirect_to [:summary, @zuckerl], notice: 'Dein Zuckerl-Guthaben wurde eingelöst'

    elsif params[:edit_zuckerl].present?
      @zuckerl.update zuckerl_params_edit
      redirect_to zuckerls_user_path, notice: 'Dein Zuckerl wurde aktualisiert'

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
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."
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
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."

      # Publish Immediate if Zuckerl is Payed and booked for current month
      last_month = Date.today.last_month
      if @zuckerl.approved? && @zuckerl.created_at >= last_month.beginning_of_month && @zuckerl.created_at <= last_month.end_of_month
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
    set_location
    set_zuckerl_or_redirect
  end

  def destroy
    set_location
    @location.zuckerls.find(params[:id]).cancel!
    redirect_to zuckerls_user_path, notice: 'Dein Zuckerl wurde gelöscht'
  end

  private

  def collection_scope
    Zuckerl.live
  end

  def valid_zuckerl_voucher_for(zuckerl)
    zuckerl.user.valid_zuckerl_voucher_for(zuckerl) || zuckerl.user.subscription&.valid_zuckerl_voucher_for(zuckerl)
  end

  def set_location_for_new
    case
    when params[:location_id].present?
      @location = current_user.locations.in(current_region).approved.find(params[:location_id])
    when current_user.locations.in(current_region).approved.count == 1
      @location = current_user.locations.in(current_region).approved.first
    else
      @locations = current_user.locations.in(current_region).approved
      render :new_location and return
    end
  end

  def set_location
  @location = current_user.zuckerls.find(params[:id]).location
  end

  def set_zuckerl_or_redirect
    @zuckerl = @location.zuckerls.where(aasm_state: ['incomplete', 'pending']).find params[:id]
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
      :amount,
      :description,
      :cover_photo,
      :remove_cover_photo,
      :entire_region,
      :link,
    )
  end

  def zuckerl_params_edit
    params.require(:zuckerl).permit(
      :title,
      :description,
      :cover_photo,
      :remove_cover_photo,
      :link,
    )
  end
end
