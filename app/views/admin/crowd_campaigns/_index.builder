context.instance_eval do
  #selectable_column
  id_column
  #column :region
  column('Start', sortable: :startdate) do |c|
    I18n.localize(c.startdate, format: '%d.%m.%y') if c.startdate?
  end
  column('Ende') do |c|
    "#{campaign_remaining_time(c).first} #{campaign_remaining_time(c).last}" if c.enddate && c.enddate >= Date.today
  end
  #column(:status){|c| status_tag(c.status)}
  #column(:funding){|c| status_tag(c.funding_status)}
  column(:title){|b| link_to b.title, admin_crowd_campaign_path(b) }
  column :user
  column '%', :service_fee_percentage
  column("Status") do |c|
    if c.funding? || c.completed?
      status_tag(c.status)
      status_tag(c.funding_status)
      status_tag(c.active_state) if c.disabled? || c.hidden?
    else
      status_tag(c.status)
    end
  end
  column(:'Boost') do |c|
    if c.boost_status.present?
      status_tag(c.crowd_boost_slot&.crowd_boost)
      status_tag(c.boost_status)
    else
      status_tag(c.crowd_boost_slot&.crowd_boost)
    end
  end
  #column(:call){|c| status_tag(c.crowdfunding_call)}
  column(:'Payout') do |c|
    status_tag(I18n.t("activerecord.attributes.crowd_campaign.transfer_status.#{c.transfer_status}")) if c.transfer_status
  end
  column(:stripe){|c| status_tag(c.user.stripe_connect_ready?)}
  column "" do |resource|
    count = AdminComment.where(resource_type: 'CrowdCampaign', resource_id: resource.id).count
    link_to count, admin_crowd_campaign_path(resource)
  end
end
