ActiveAdmin.register User do
  #include ViewInApp
  menu priority: 3


  scope :all, default: true
  scope :business
  scope :admin

  # index
  index do
    render 'index', context: self
  end

  # filter
  filter :graetzl
  filter :username
  filter :first_name
  filter :last_name
  filter :email
  filter :role, as: :select, collection: User.roles.keys
  filter :created_at
  filter :updated_at

  # show
  show do
    render 'show', context: self
  end

  # form
  form partial: 'form'

  # strong parameters (maybe something missing)
  permit_params :graetzl_id,
    :username,
    :first_name,
    :last_name,
    :email,
    :password,
    :newsletter,
    :bio,
    :website,
    :avatar,
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :description,
      :coordinates]


end
