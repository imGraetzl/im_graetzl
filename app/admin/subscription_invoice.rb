ActiveAdmin.register SubscriptionInvoice do
  menu parent: 'Subscriptions'
  actions :all, except: [:new, :create, :destroy, :edit]

  index { render 'index', context: self }
end
