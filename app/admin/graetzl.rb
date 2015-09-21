ActiveAdmin.register Graetzl do
  menu priority: 2

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

  # form
  form partial: 'form'

  # strong params
  permit_params :name, :state, :slug, :area

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
end
