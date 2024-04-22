context.instance_eval do
  columns do
    column do
    
      panel 'Basic Details' do
        attributes_table_for crowd_boost do
          row :id
          row(:status){|b| status_tag(b.status)}
          row :title
          row :slogan
          row :description
          row :threshold_pledge_count
          row :threshold_funding_percentage
          row :boost_amount
          row :boost_precentage
          row :avatar do |l|
            l.avatar && image_tag(l.avatar_url(:thumb))
          end
        end
      end

    end
    column do

      panel 'Saldo' do
        attributes_table_for crowd_boost do
          row(:balance){|b| b.balance}
          row(:total_amount_charged){|b| b.total_amount_charged}
          row(:total_amount_pledged){|b| b.total_amount_pledged}
        end
      end

      panel 'CrowdBoostSlots' do
        table_for crowd_boost.crowd_boost_slots do
          column :id
          column(:active){|b| b.active?}
          column :starts_at
          column :ends_at
          column(''){|b| link_to 'Boost Slot Anzeigen', admin_crowd_boost_slot_path(b) }
        end
      end

    end
  end
  columns do
    panel 'Campaigns' do
      table_for crowd_boost.crowd_campaigns do
        column(:campaign){|c| c}
        column(:funding_status){|c| status_tag(c.funding_status)}
        column(:boost_status){|c| status_tag(c.boost_status)}
        column(:pledges){|c| c.crowd_boost_pledges.count}
        column(:crowd_boost_sum){|c| c.crowd_boost_pledges_sum}
        column(:boost_slot){|c| c.crowd_boost_slot}
      end
    end
  end
end
