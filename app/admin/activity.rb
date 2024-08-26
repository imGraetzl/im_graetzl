ActiveAdmin.register Activity do
  menu parent: 'Einstellungen'
  actions :all, except: [:new, :edit]


end
