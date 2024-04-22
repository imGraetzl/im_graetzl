context.instance_eval do
  columns do
    column do
    
      panel 'Basic Details' do
        attributes_table_for crowd_boost_slot do
          row :id
          row(:active){|b| b.active?}
          row :amount_limit
          row :max_campaigns
          row :starts_at
          row :ends_at
        end
      end

    end
    column do

      panel 'Saldo' do
        attributes_table_for crowd_boost_slot do
          row(:balance){|b| b.balance}
          row(:total_amount_initialized){|b| b.total_amount_initialized}
          row(:total_amount_pledged){|b| b.total_amount_pledged}
        end
      end

    end
  end
  columns do
    panel 'Campaigns' do
      table_for crowd_boost_slot.crowd_campaigns do
        column(:campaign){|c| c}
        column(:funding_status){|c| status_tag(c.funding_status)}
        column(:boost_status){|c| status_tag(c.boost_status)}
        column(:pledges){|c| c.crowd_boost_pledges.count}
        column(:crowd_boost_sum){|c| c.crowd_boost_pledges_sum}
      end
    end
  end
end
