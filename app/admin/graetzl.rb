ActiveAdmin.register Graetzl do

  # scopes
  scope :all, default: true
  scope :open
  scope :closed

  # index
  index do
    render 'index', context: self
  end

  # show
  show do
    render 'show', context: self
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  # index





end
