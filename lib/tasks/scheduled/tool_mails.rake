namespace :scheduled do

  desc 'Reminder for Tool expiring'
  task reminder_tool_expiring: :environment do

    ToolDemand.enabled.where("usage_period_to = ?", Date.yesterday).find_each do |tool_demand|
      tool_demand.update_attribute(:status, "disabled")
      tool_demand.destroy_activity_and_notifications
      ToolMailer.tool_demand_activate_reminder(tool_demand).deliver_later
    end

  end
end
