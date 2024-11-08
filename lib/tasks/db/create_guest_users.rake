namespace :db do
  desc "Erstellt Gast-Benutzer für CrowdPledges ohne User"
  task create_guests_from_pledges: :environment do
    Rails.logger.info "Starting task: create_guests_from_pledges"

    created_users_count = 0
    failed_users_count = 0
    failed_emails = []
    email = nil # Definiere die Variable außerhalb des Blocks

    begin
      CrowdPledge.initialized.where(user_id: nil)
                 .group_by(&:email)
                 .each do |current_email, pledges|
        # Konvertiere die E-Mail in Kleinbuchstaben
        email = current_email.downcase

        # Wähle den ältesten CrowdPledge pro E-Mail
        oldest_pledge = pledges.min_by(&:created_at)

        # Prüfe, ob ein Benutzer mit der Kleinbuchstaben-E-Mail existiert
        user = User.find_by(email: email)

        if user.nil?
          # Erstelle einen neuen Gast-Benutzer, wenn keiner existiert und speichere die E-Mail in Kleinbuchstaben
          user = User.create!(
            guest: true,
            email: email, # Kleinbuchstaben-E-Mail verwenden
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
        elsif user.guest?
          # Wenn ein Gast-Benutzer existiert, verwende diesen Benutzer
          Rails.logger.info "Existing guest user found with email #{user.email} and ID #{user.id}. Using this user."
        else
          # Überspringe reguläre Benutzer
          Rails.logger.info "Skipping email #{email} because it is assigned to a regular (non-guest) user."
          next
        end

        # Aktualisiere alle CrowdPledges mit derselben Kleinbuchstaben-E-Mail und ohne user_id
        updated_count = CrowdPledge.where(email: email, user_id: nil).update_all(user_id: user.id)
        Rails.logger.info "Updated #{updated_count} CrowdPledges for user ID: #{user.id}, email: #{email}"
      end
    rescue ActiveRecord::RecordInvalid => e
      failed_users_count += 1
      failed_emails << email
      Rails.logger.error "Failed to create guest user for email #{email}. Error: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "An error occurred during the task: #{e.message}"
    end

    Rails.logger.info "Task complete: create_guests_from_pledges"
    Rails.logger.info "Summary: #{created_users_count} guest users created, #{failed_users_count} failed to create."
    Rails.logger.info "Failed emails: #{failed_emails.join(', ')}" unless failed_emails.empty?
  end
end
