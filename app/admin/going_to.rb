ActiveAdmin.register GoingTo do
  menu parent: 'Meetings'
  includes :meeting, :user
  actions :all, except: [:new, :create, :edit]

  config.sort_order = 'created_at_desc'

  scope :attendee, default: true
  scope :initiator

  filter :meeting, collection: proc { Meeting.order(:starts_at_date).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}

  index { render 'index', context: self }

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
    def apply_filtering(chain)
        super(chain).distinct
    end
  end

  csv do
    column :meeting
    column(:full_name) {|going_to| going_to.user.full_name if going_to.user }
    column(:email) {|going_to| going_to.user.email if going_to.user }
    column :going_to_date
    column :created_at
  end

end
