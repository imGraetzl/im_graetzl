ActiveAdmin.register User do

  # permit which attributes may be changed
  permit_params :username, :first_name, :last_name, :email, :birthday, :gender, :newsletter, :admin, :avatar,
      address_attributes: [:id, :street_name, :street_number, :zip, :city, :description, :coordinates]

  # customize views

  # index
  index do
    selectable_column
    id_column
    column :username
    column :email
    column :first_name
    column :last_name
    column :graetzl do |user|
      user.graetzl.short_name
    end
    actions
  end

  # form
  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs          # builds an input field for every attribute

    f.inputs 'Addresse' do
      f.semantic_fields_for [:address, (f.object.address || f.object.build_address)] do |a| 
        a.input :street_name
        a.input :street_number
        a.input :zip
        a.input :city
        a.input :description
        a.input :coordinates, as: :string
      end
    end
    f.actions
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


end
