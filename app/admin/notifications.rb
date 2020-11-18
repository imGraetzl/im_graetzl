ActiveAdmin.register Notification, as: "Notifications" do
  menu parent: 'Users', priority: 3

  scope :all, default: true
  scope :ready_to_be_sent

  index { render 'index', context: self }

end
