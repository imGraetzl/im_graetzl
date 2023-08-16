ActiveAdmin.register DiscussionDefaultCategory do
  menu parent: 'Einstellungen'

  permit_params :title
end
