context.instance_eval do
  selectable_column
  id_column
  #column :region
  column ('Start') {|c| I18n.localize(c.startdate, format:'%d.%m.%y') if c.startdate?}
  column(:title){|b| link_to b.title, admin_crowd_campaign_path(b) }
  column :user
  column '%', :service_fee_percentage
  column(:status){|c| status_tag(c.status)}
  column(:funding){|c| status_tag(c.funding_status)}
  column(:call){|c| status_tag(c.crowdfunding_call)}
  column(:'Boost'){|c| status_tag(c.boost_status)}
  column(:stripe){|c| status_tag(c.user.stripe_connect_ready?)}
  column :closed?
end
