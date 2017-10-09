ActiveAdmin.register RoomCategory do
  menu parent: 'Rooms'

  permit_params :name
end
