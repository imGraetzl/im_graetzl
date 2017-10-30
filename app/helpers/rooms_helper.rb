module RoomsHelper

  def filter_room_types
    [
      ['Alle Räume', 'offer', 'data-label' => 'Alle Räume'],
      ['Räume zum Einmieten', 'offer-0', 'data-label' => 'Räume zum Einmieten'],
      ['Räume zum Neuanmieten', 'offer-1', 'data-label' => 'Räume zum Neuanmieten'],
      ['Alle Raumsuchende', 'demand', 'data-label' => 'Alle Raumsuchende'],
      ['Raumsuchende zum Einmieten', 'demand-0', 'data-label' => 'Raumsuchende zum Einmieten'],
      ['Raumsuchende zur gemeinsamen Neuanmietung', 'demand-1', 'data-label' => 'Raumsuchende zur gemeinsamen Neuanmietung'],
    ]
  end

end
