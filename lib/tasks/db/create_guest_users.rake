namespace :db do
  desc "Erstellt Gast-Benutzer für CrowdPledges ohne User"
  task create_guests_from_pledges: :environment do
    Rails.logger.info "Starting task: create_guests_from_pledges"

    created_users_count = 0
    failed_users_count = 0
  
    begin
      CrowdPledge.initialized.where(user_id: nil)
                 .group_by(&:email)
                 .each do |email, pledges|
  
        # Wähle den ältesten CrowdPledge pro E-Mail
        oldest_pledge = pledges.min_by(&:created_at)
        Rails.logger.info "Processing pledges for email: #{email}, oldest pledge ID: #{oldest_pledge.id}"
  
        # Erstelle oder finde den Gast-Benutzer für die E-Mail
        user = User.create!(
          guest: true,
          email: email,
          first_name: oldest_pledge.first_name,
          last_name: oldest_pledge.last_name,
          address_street: oldest_pledge.address_street,
          address_zip: oldest_pledge.address_zip,
          address_city: oldest_pledge.address_city,
          business: false,
          region_id: oldest_pledge.region_id,
          stripe_customer_id: oldest_pledge.stripe_customer_id,
          created_at: oldest_pledge.created_at
        )
        created_users_count += 1
        Rails.logger.info "Guest user created with email #{user.email} and ID #{user.id}"
  
        # Aktualisiere alle CrowdPledges mit derselben E-Mail und ohne user_id
        updated_count = CrowdPledge.where(email: email, user_id: nil).update_all(user_id: user.id)
        Rails.logger.info "Updated #{updated_count} CrowdPledges for user ID: #{user.id}, email: #{email}"
      end
    rescue ActiveRecord::RecordInvalid => e
      failed_users_count += 1
      Rails.logger.error "Failed to create guest user for email #{email}. Error: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "An error occurred during the task: #{e.message}"
    end
  
    Rails.logger.info "Task complete: create_guests_from_pledges"
    Rails.logger.info "Summary: #{created_users_count} guest users created, #{failed_users_count} failed to create."

  end
  
end
