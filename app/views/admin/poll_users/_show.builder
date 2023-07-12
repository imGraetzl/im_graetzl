context.instance_eval do
  panel 'Umfrage User' do
    attributes_table_for poll_user do
      row :poll
      row :user
      row :created_at
    end
  end
  panel 'Antworten' do
    table_for poll_user.poll_user_answers do
      column :poll_question
      column :poll_option
      column :answer
    end
  end
end
