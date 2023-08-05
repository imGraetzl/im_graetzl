ActiveAdmin.register SubscriptionInvoice do
  menu parent: 'Subscriptions'
  actions :all, except: [:new, :create, :destroy, :edit]

  scope :all, default: true
  scope :paid
  scope :free

  index { render 'index', context: self }
end
