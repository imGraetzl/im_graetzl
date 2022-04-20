context.instance_eval do
  panel 'Unterstützung' do
    attributes_table_for crowd_donation_pledge.crowd_donation do
      row :title
      row :answer
    end
    attributes_table_for crowd_donation_pledge do
      row :crowd_campaign
      row(:donation_type){|r| status_tag(r.donation_type)}
      row :id
      row :email
      row :contact_name
      row :user
      row :created_at
    end
  end
  panel 'Kontaktdaten' do
    attributes_table_for crowd_donation_pledge do
      row :contact_name
      row :address_street
      row :address_zip
      row :address_city
    end
  end

end
