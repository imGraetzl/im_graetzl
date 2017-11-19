module RoomsHelper

  def filter_room_types
    [
      ['Alle Raumteiler', ''],
      ['Räume', 'offer-0'],
      ['Räume zur gemeinsamen Neuanmietung', 'offer-1'],
      ['Raumsuchende', 'demand-0'],
      ['Raumsuchende zur gemeinsamen Neuanmietung', 'demand-1'],
    ]
  end

end
