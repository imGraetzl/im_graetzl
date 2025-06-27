ActiveAdmin.register DiscussionDefaultCategory do
  menu parent: 'Einstellungen'
  config.filters = false
  permit_params :title
end
