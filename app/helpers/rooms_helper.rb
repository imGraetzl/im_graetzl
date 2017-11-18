module RoomsHelper

  def filter_room_types
    [
      ['Alle Raumteiler', ''],
      ['Räume zum Andocken', 'offer-0'],
      ['Räume zur gemeinsamen Neuanmietung', 'offer-1'],
      ['Raumsuchende zum Andocken', 'demand-0'],
      ['Raumsuchende zur gemeinsamen Neuanmietung', 'demand-1'],
    ]
  end

end
