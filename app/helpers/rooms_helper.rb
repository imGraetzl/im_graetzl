module RoomsHelper

  def filter_room_types
    [
      ['Alle Raumteiler', ''],
      ['Alle Räume', 'offer'],
      ['Räume zum Einmieten', 'offer-0'],
      ['Räume zur Neuanmietung', 'offer-1'],
      ['Alle Raumsuchende', 'demand'],
      ['Raumsuchende zum Einmieten', 'demand-0'],
      ['Raumsuchende zur gemeinsamen Neuanmietung', 'demand-1'],
    ]
  end

end
