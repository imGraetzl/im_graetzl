ActiveAdmin.register GoingTo do
  menu parent: 'Meetings'
  includes :meeting, :user
  actions :all, except: [:new, :create, :edit]

  config.sort_order = 'created_at_desc'

  scope :attendee, default: true
  scope :initiator

  filter :meeting, collection: proc { Meeting.order(:starts_at_date).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
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
