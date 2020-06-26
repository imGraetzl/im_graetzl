module RoomsHelper

  def filter_room_types
    [
      ['Alle Raumteiler', ''],
      ['Räume', 'offer'],
      ['Raumsuchende', 'demand'],
      #['Open Calls', 'call'],
      #['Raumteiler Gruppen', 'with_group']
    ]
  end

  def room_discount_values
    [5, 10, 15, 20, 25, 30, 40, 50].map do |value|
      ["#{value} %", value]
    end
  end

end
