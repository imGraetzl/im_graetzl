context.instance_eval do
  selectable_column
  id_column
  #column :region
  column ('Start') {|c| I18n.localize(c.startdate, format:'%d.%m.%y') if c.startdate?}
  column :title
  column :user
  column '%', :service_fee_percentage
  column(:status){|c| status_tag(c.status)}
  column(:funding){|c| status_tag(c.funding_status)}
  column(:stripe){|c| status_tag(c.user.stripe_connect_ready?)}
  #column(:visibility){|c| status_tag(c.visibility_status)}
  column :closed?
  column(:call){|c| status_tag(c.crowdfunding_call)}
  actions
end
