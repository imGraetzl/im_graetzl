ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do
  actions :index, :show, :update, :edit, :destroy
  menu parent: :locations
  config.filters = false

  index { render 'index', context: self }
  show { render 'show', context: self }

  permit_params :name
end
