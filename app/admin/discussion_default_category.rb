ActiveAdmin.register DiscussionDefaultCategory do
  menu parent: 'Groups'

  permit_params :title
end
