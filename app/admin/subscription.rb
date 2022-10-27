ActiveAdmin.register Subscription do
  menu parent: 'Users'
  actions :all, except: [:destroy, :edit]

  scope :all, default: true
  scope :incomplete
  scope :active
  scope :canceled
  scope :past_due

  index { render 'index', context: self }

end
