ActiveAdmin.register User do
  include ViewInApp
  menu priority: 3
  includes :graetzl

  scope :all, default: true
  scope :business
  scope :admin

  filter :graetzl
  filter :username
  filter :first_name
  filter :last_name
  filter :email
  filter :role, as: :select, collection: User.roles.keys
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :graetzl_id,
    :username,
    :first_name,
    :last_name,
    :email,
    :password,
    :newsletter,
    :bio,
    :website,
    :avatar, :remove_avatar,
    :cover_photo, :remove_cover_photo,
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :description,
      :coordinates]

    csv do
      column :id
      column :email
      column :username
      column :first_name
      column :last_name
      column(:graetzl) { |user| user.graetzl.name }
      column :last_sign_in_at
      column :created_at
      column :confirmed_at
      column :role
      column :slug
      column :bio
      column :website
      column :newsletter
      column(:bezirk_1) { |user| user.graetzl.districts.first.try(:zip) }
      column(:bezirk_2) { |user| user.graetzl.districts.second.try(:zip) }
      column(:bezirk_3) { |user| user.graetzl.districts.third.try(:zip) }
      column(:location_1) { |user| user.locations.first.try(:name) }
      column(:location_2) { |user| user.locations.second.try(:name) }
      column(:location_3) { |user| user.locations.third.try(:name) }
    end
end
