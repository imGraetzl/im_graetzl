module EnergyHelper

  def filter_energy_types
    [
      ['Alle Energieteiler', ''],
      ['Bestehende Energiegemeinschaften', 'offer'],
      ['Suche nach Energiegemeinschaften', 'demand'],
      ['Energieteiler Treffen', 'meeting'],

    ]
  end

  def member_count_values
    [
      ["unter 5", "to_5"],
      ["5 bis 10", "5_to_10"],
      ["10 bis 20", "10_to_20"],
      ["20 bis 50", "20_to_50"],
      ["über 50", "50_to"],
    ]
  end

  def member_count_names(value)
    case value
    when 'to_5'
      "1 bis 5"
    when '5_to_10'
      "5 bis 10"
    when '10_to_20'
      "10 bis 20"
    when '20_to_50'
      "20 bis 50"
    when '50_to'
      "über 50"
    else
      false
    end
  end

  def organization_form_offer_options
    EnergyOffer.organization_forms.map{|o| [t("activerecord.attributes.energy_offer.organization_forms.#{o[0]}"), o[0]]}
  end

  def organization_form_demand_options
    EnergyDemand.organization_forms.map{|o| [t("activerecord.attributes.energy_demand.organization_forms.#{o[0]}"), o[0]]}
  end

  def orientation_type_demand_options
    EnergyDemand.orientation_types.map{|o| [t("activerecord.attributes.energy_demand.orientation_types.#{o[0]}"), o[0]]}
  end

end
