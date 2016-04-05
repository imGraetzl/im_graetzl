ActiveAdmin.register Category do
  config.filters = false

  scope :all, default: true
  scope :business
  scope :recreation

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :name, :icon, :context
end
