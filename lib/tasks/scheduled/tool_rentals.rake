namespace :scheduled do

  desc 'Update Completed Rentals to Return Pending State'
  task update_completed_tool_rentals: :environment do
    ToolRental.approved.where("rent_to < ?", Date.today).find_each do |tool_rental|
      tool_rental.update(rental_status: :return_pending)
      ToolOfferMailer.rental_return_pending(tool_rental).deliver_now
    end
  end

  desc 'Send Reminder to ToolOffer Owner for Pending Rentals'
  task owner_reminder_pending_tool_rentals: :environment do
    ToolRental.pending.where("created_at < ?", Date.today - 4.days).find_each do |tool_rental|
      ToolOfferMailer.new_rental_request_reminder(tool_rental).deliver_now
    end
  end

end
