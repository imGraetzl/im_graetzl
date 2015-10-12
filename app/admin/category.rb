ActiveAdmin.register Category do
  config.filters = false

  scope :all, default: true
  scope :business
  scope :recreation

  # index
  index do
    render 'index', context: self
  end

  # show
  show do
    render 'show', context: self
  end

  # form
  form partial: 'form'

  # permit which attributes may be changed
  permit_params :name, :context  
end
