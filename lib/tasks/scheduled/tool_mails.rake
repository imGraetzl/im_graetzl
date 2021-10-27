namespace :scheduled do

  desc 'Reminder for Tool expiring'
  task reminder_tool_expiring: :environment do

    ToolDemand.enabled.where("usage_period_to = ?", Date.yesterday).find_each do |tool_demand|
      tool_demand.update_attribute(:status, "disabled")
      ToolMailer.tool_demand_activate_reminder(tool_demand).deliver_now
    end

  end
end
