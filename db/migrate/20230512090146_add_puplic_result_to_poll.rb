class AddPuplicResultToPoll < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :public_result, :boolean, default: false
    add_column :poll_questions, :main_question, :boolean, default: false
    add_column :poll_questions, :votes_count, :integer, default: 0
    add_column :poll_options, :votes_count, :integer, default: 0
  end
end
