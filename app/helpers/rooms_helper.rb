module RoomsHelper

  def filter_room_types
    [
      ['Alle Raumteiler', ''],
      ['Räume zum Einmieten', 'offer-0'],
      ['Räume zur Neuanmietung', 'offer-1'],
      ['Raumsuchende zum Einmieten', 'demand-0'],
      ['Raumsuchende zur gemeinsamen Neuanmietung', 'demand-1'],
    ]
  end

end
