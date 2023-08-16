context.instance_eval do
  panel 'Umfrage User' do
    attributes_table_for poll_user do
      row :poll
      row :user
      row :created_at
    end
  end
  poll_user.poll.poll_questions.order(:position).each do |question|
    panel question.title do
      question.poll_user_answers.where(poll_user_id: poll_user.id).each do |answer|
        columns answer.poll_option
        columns answer.answer
      end
    end
  end
  
end
