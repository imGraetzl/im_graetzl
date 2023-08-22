class AddPublicCommentToPollUserAnswer < ActiveRecord::Migration[6.1]
  def change
    add_column :poll_user_answers, :public_comment, :boolean, default: false, null: false
  end
end
