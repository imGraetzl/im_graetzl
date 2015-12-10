ActiveAdmin.register ActsAsTaggableOn::Tag, as: 'Tag' do
  actions :index, :show, :update, :edit, :destroy
  menu parent: 'Locations'

  # index
  index do
    render 'index', context: self
  end

  # show
  show do
    render 'show', context: self
  end
end
