ActiveAdmin.register PollUser do
  menu parent: 'Einstellungen'
  actions :all, except: [:new, :edit]

  scope :all, default: true
  filter :user, collection: proc { User.registered.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :poll, collection: proc { Poll.all }, include_blank: true, input_html: { class: 'admin-filter-select'}

  index { render 'index', context: self }
  show { render 'show', context: self }

  controller do
    def apply_pagination(chain)
        chain = super unless formats.include?(:json) || formats.include?(:csv)
        chain
    end
  end

  csv do
    column :id
    column(:plz) {|poll_user| poll_user.poll.zip }
    column :poll
    column(:name)   {|poll_user| poll_user.user.full_name}
    column(:email)  {|poll_user| poll_user.user.email}

    column(:poll_user_answers) {|poll_user| poll_user.poll_user_answers.map(&:poll_option).join(", ") }
    column(:free_answers) {|poll_user| poll_user.poll_user_answers.map(&:answer).join(", ") }
    column :created_at
  end

end
