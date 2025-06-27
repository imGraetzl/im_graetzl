ActiveAdmin.register Activity do
  menu parent: 'Einstellungen'
  actions :all, except: [:new, :edit]

  remove_filter :activity_graetzls
  remove_filter :graetzls

end
