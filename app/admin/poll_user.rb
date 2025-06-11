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

    def scoped_collection
      super.includes(:user, :poll, poll_user_answers: [:poll_option, :poll_question])
    end
  end

  csv do
    column :id
    column(:poll) { |poll_user| poll_user.poll&.title }
    column(:name) { |poll_user| poll_user.user&.full_name }
    column(:email) { |poll_user| poll_user.user&.email }
    column :created_at

    # Dynamische Fragen-Spalten:
    poll_ids = collection.map(&:poll_id).compact.uniq
    poll = Poll.includes(poll_questions: :poll_options).find_by(id: poll_ids.first)

    if poll.present?
      poll.poll_questions.each do |question|
        column(question.title) do |poll_user|
          answers = poll_user.poll_user_answers.select do |answer|
            answer.poll_question_id == question.id
          end

          answers.map do |answer|
            answer.poll_option&.title.presence || answer.answer.presence
          end.compact.join(", ")
        end
      end
    end
  end

end
