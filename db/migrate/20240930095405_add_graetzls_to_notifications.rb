class AddGraetzlsToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :daily_send_at, :date
    add_column :notifications, :weekly_send_at, :date
    add_reference :notifications, :graetzl, index: true
  end
end