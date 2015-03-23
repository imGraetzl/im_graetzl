class AddNewsletterToUser < ActiveRecord::Migration
  def change
    add_column :users, :newsletter, :boolean, null: false, default: false
  end
end
