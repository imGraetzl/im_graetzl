class RoomBoostersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_room_offer, only: [:new, :create]

  def new

    if @room_offer.disabled?
      flash[:notice] = "Dein Raumteiler ist aktuell inaktiv und kann nicht geboostert werden. Aktiviere diesen zuvor."
      redirect_to @room_offer and return
    #elsif @room_offer.boosted?
      #flash[:notice] = "Dieser Raumteiler wird gerade geboostert. #{view_context.link_to 'Zurück zur Booster Übersicht', room_boosters_user_url}"
      #redirect_to @room_offer
    end

    @room_booster = @room_offer.room_boosters.build(initial_booster_params)
    @room_booster.assign_attributes(current_user_params)

    if RoomBooster.in(@room_offer.region).active.count < 2
      @next_start_date = Date.today
    else
      @next_start_date = RoomBooster.in(@room_offer.region).active.sort_by(&:ends_at_date).first.ends_at_date + 1.day
      flash.now[:notice] = "Der nächste freie Booster Start ist am #{I18n.localize(@next_start_date, format:'%A, den %d.%m.%Y')}. Fahre jetzt fort um deinen Booster zu aktivieren."
    end

    @room_booster.starts_at_date = @next_start_date
    @room_booster.send_at_date = @next_start_date.next_occurring(:tuesday)
    @room_booster.ends_at_date = @next_start_date + 7.days

  end

  def create
    @room_booster = @room_offer.room_boosters.build(room_booster_params)

    @room_booster.user_id = current_user.id
    @room_booster.region_id = @room_offer.region_id
    @room_booster.amount = @room_booster.total_price / 100
    @room_booster.status = "incomplete"

    if @room_booster.save

      if current_user.admin? && params[:freeadmin].present?
        RoomBoosterService.new.create_for_free(@room_booster)
        redirect_to [:summary, @room_booster]
      else
        redirect_to [:choose_payment, @room_booster]
      end

    else
      render :new
    end
  end

  def choose_payment
    @room_booster = RoomBooster.find(params[:id])
    @room_offer = @room_booster.room_offer

    redirect_to [:summary, @room_booster] and return if !@room_booster.incomplete?

    @payment_intent = RoomBoosterService.new.create_payment_intent(@room_booster)

  end

  def payment_authorized
    @room_booster = RoomBooster.find(params[:id])
    @room_offer = @room_booster.room_offer

    redirect_to [:summary, @room_booster] if params[:payment_intent].blank?

    success, error = RoomBoosterService.new.payment_authorized(@room_booster, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."
      redirect_to [:summary, @room_booster]
    else
      flash[:error] = error
      redirect_to [:choose_payment, @room_booster]
    end

  end

  def summary
    @room_booster = RoomBooster.find(params[:id])
    @room_offer = @room_booster.room_offer

  end

  private

  def load_room_offer
    case
    when params[:room_offer_id].present?
      @room_offer = current_user.room_offers.in(current_region).find(params[:room_offer_id])
    when current_user.room_offers.in(current_region).enabled.count == 1
      @room_offer = current_user.room_offers.in(current_region).enabled.first
    else
      @room_offers = current_user.room_offers.in(current_region)
      if @room_offers.blank?
        flash[:notice] = "Du hast noch keinen Raumteiler zum Boosten. Neuen #{view_context.link_to 'Raumteiler erstellen', select_room_offers_path}"
        redirect_to room_boosters_user_url and return
      else
        render :choose_room_offer and return
      end
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

  def initial_booster_params
    params.permit(:room_offer_id, :amount)
  end

  def room_booster_params
    params.require(:room_booster).permit(
      :amount, :send_at_date,
      :name, :company, :address, :zip, :city
    )
  end

end
