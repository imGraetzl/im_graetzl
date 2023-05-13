ActiveAdmin.register Poll do
  include ViewInApp
  menu parent: 'Einstellungen'

  includes :poll_questions, :poll_options, :poll_users
  actions :all

  scope :all, default: true
  scope :enabled
  scope :closed
  scope :disabled

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :status
  filter :poll_type
  filter :title
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :status, :poll_type, :title, :description, :region_id,
    :cover_photo, :remove_cover_photo, :user_id, :public_result,
    graetzl_ids: [],
    poll_questions_attributes: [
      :id, :option_type, :required, :title, :description, :main_question, :_destroy,
      poll_options_attributes: [:id, :title, :_destroy]
    ]

  # Within app/admin/resource_name.rb
  # Controller pagination overrides

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end

end
