ActiveAdmin.register GoingTo do
  menu parent: 'Treffen'
  includes :meeting, :user
  actions :all, except: [:new, :create, :destroy, :edit]

  scope :paid_attendee, default: true
  scope :payment_success
  scope :payment_pending
  scope :payment_failed
  scope :payment_refunded

  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

end
