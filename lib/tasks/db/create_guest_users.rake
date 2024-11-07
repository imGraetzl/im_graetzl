namespace :db do
  desc "Erstellt Gast-Benutzer für CrowdPledges ohne User"
  task create_guests_from_pledges: :environment do

    CrowdPledge.where(user_id: nil)
           .group_by(&:email)
           .each do |email, pledges|

      # Wähle den ältesten CrowdPledge pro E-Mail
      oldest_pledge = pledges.min_by(&:created_at)

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
        origin: oldest_pledge.origin,
        region_id: oldest_pledge.region_id,
        stripe_customer_id: oldest_pledge.stripe_customer_id,
        created_at: oldest_pledge.created_at
      )

      # Aktualisiere alle CrowdPledges mit derselben E-Mail und ohne user_id
      CrowdPledge.where(email: email, user_id: nil).update_all(user_id: user.id)

      puts "Gast-Benutzer erstellt mit E-Mail #{user.email} und ID #{user.id}."
    end

  end
end
