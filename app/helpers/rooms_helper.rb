module RoomsHelper

  def room_type_filter_selection
    if params[:room_offer_type].blank? && params[:room_demand_type].blank?
      return "Alle Raumteiler"
    end

    if params[:room_offer_type].present?
      room_offer_type = {'0' => 'Räume zum Einmieten', '1' => 'Räume zum Neuanmieten'}[params[:room_offer_type]]
    else
      room_offer_type = 'Alle Räume'
    end

    if params[:room_demand_type].present?
      room_demand_type = {'0' => 'Raumsuchende zum Einmieten', '1' => 'Raumsuchende zur gemeinsamen Neuanmietung'}[params[:room_demand_type]]
    else
      room_demand_type = 'Alle Raumsuchende'
    end

    [room_offer_type, room_demand_type].join(', ')
  end

end
