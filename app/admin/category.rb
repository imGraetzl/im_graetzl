ActiveAdmin.register Category do

  scope 'Alle', :all, default: true
  scope :recreation
  scope :business

  # permit which attributes may be changed
  permit_params :name, :context

  index do
    selectable_column
    column(:name) { |c| link_to c.name, admin_category_path(c) }
    column(:context) { |c|  status_tag(c.context) }
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table_for category do
      row :id
      row :name
      row :created_at
      row :updated_at
      row :context do |category|
        status_tag category.context
      end
    end
  end

  # form
  form do |f|
    semantic_errors *f.object.errors.keys
    inputs do
      f.input :name
      f.input :context, as: :select, collection: Category.contexts.keys
    end
    actions
  end
  
end
