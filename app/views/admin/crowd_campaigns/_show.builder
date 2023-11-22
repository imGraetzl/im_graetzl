context.instance_eval do
  columns do
    column do
      panel 'Basic Details' do
        attributes_table_for crowd_campaign do
          row :id
          row :service_fee_percentage
          row :region
          row :graetzl
          row :user
          row(:stripe_connect_account_id){|l| l.user.stripe_connect_account_id}
          row(:stripe_connect_ready){|l| l.user.stripe_connect_ready}
          row(:active_state){|l| status_tag(l.active_state)}
          row(:status){|l| status_tag(l.status)}
          row(:funding_status){|l| status_tag(l.funding_status)}
          row :title
          row :slug
          row :slogan
          row :startdate
          row :enddate
          row :funding_1_amount
          row :funding_1_description
          row :funding_2_amount
          row :funding_2_description
          row :billable
          row :video
          row :crowd_categories do |e|
            safe_join(
              e.crowd_categories.map do |category|
                content_tag(:span, link_to(category.title, admin_crowd_category_path(category))) + ', '
              end
            )
          end
          row :created_at
          row :updated_at
          row :address_street
          row :address_zip
          row :address_city
          row :description
          row :support_description
          row :aim_description
          row :about_description
          row :benefit
          row :benefit_description
          row :cover_photo do |l|
            l.cover_photo && image_tag(l.cover_photo_url(:thumb))
          end
          row :avatar do |l|
            l.avatar && image_tag(l.avatar_url(:thumb))
          end
          row :images do
            crowd_campaign.images.map do |image|
              image_tag image.file_url(:thumb)
            end
          end
        end
      end

      panel 'Kontaktdaten' do
        attributes_table_for crowd_campaign do
          row :id
          row :contact_email
          row :contact_name
          row :contact_company
          row :contact_website
          row :contact_phone
          row :contact_address
          row :contact_zip
          row :contact_city
        end
      end

    end
    column do

      if crowd_campaign.completed?
        panel 'Auszahlungsstatistik' do
          attributes_table_for crowd_campaign do
            row :transaction_fee_percentage
            row :funding_sum
            row :crowd_pledges_failed_sum
            row :effective_funding_sum
            row :crowd_pledges_fee
            row :crowd_pledges_fee_tax
            row :crowd_pledges_fee_netto
            #row :crowd_pledges_fee_owner
            row :crowd_pledges_fee_owner_netto
            row :crowd_pledges_payout
            row :invoice_number
            row(:invoice) { |r| link_to "PDF", r.invoice.presigned_url(:get) } if crowd_campaign.invoice_number?
          end
        end
      end

      panel 'Dankeschöns' do
        table_for crowd_campaign.crowd_rewards do
          column 'Betrag', :amount
          column 'Titel', :title
        end
      end
      panel 'Zeitspenden' do
        table_for crowd_campaign.crowd_donations.material do
          column :title
        end
      end
      panel 'Materialspenden' do
        table_for crowd_campaign.crowd_donations.assistance do
          column :title
        end
      end
      panel 'Raumspenden' do
        table_for crowd_campaign.crowd_donations.room do
          column :title
        end
      end
    end
  end
end
