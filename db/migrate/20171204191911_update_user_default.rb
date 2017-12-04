class UpdateUserDefault < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :weekly_mail_notifications, :integer, default: 0
    change_column :users, :daily_mail_notifications, :integer, default: 0
    change_column :users, :immediate_mail_notifications, :integer, default: 0
    change_column :users, :enabled_website_notifications, :integer, default: 0
  end
end
