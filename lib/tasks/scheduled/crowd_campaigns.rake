namespace :scheduled do

  desc 'Daily update to Campaigns'
  task crowd_campaigns_upkeep: :environment do

    task_starts_at = Time.now

    # Start scheduled campaigns
    campaign_start = Date.tomorrow.in_time_zone("Vienna").beginning_of_day.utc

    CrowdCampaign.approved.where(startdate: Date.tomorrow).find_each do |campaign|
      CrowdCampaignService.new.delay(run_at: campaign_start).start(campaign)
    end

    # Send email to funding campaign after 7 days
    CrowdCampaign.funding.where(startdate: 7.days.ago).find_each do |campaign|
      CrowdCampaignMailer.keep_up(campaign).deliver_later
    end

    # Complete expired
    campaign_end = Date.today.in_time_zone("Vienna").end_of_day.utc

    CrowdCampaign.funding.where(enddate: Date.today).find_each do |campaign|
      CrowdCampaignService.new.delay(run_at: campaign_end).complete(campaign)
    end

    # Close and generate Invoice after 14 Days
    CrowdCampaign.completed.successful.where(enddate: 13.days.ago).find_each do |campaign|
      CrowdCampaignService.new.close(campaign)
    end

    # Send Reminder email to failed Pledges after 5 Days
    CrowdCampaign.completed.where(enddate: 4.days.ago).find_each do |campaign|
      campaign.crowd_pledges.failed.find_each do |pledge|
        CrowdCampaignMailer.crowd_pledge_failed_reminder(pledge).deliver_later
      end
    end

    task_ends_at = Time.now
    AdminMailer.task_info('crowd_campaigns_upkeep', 'finished', task_starts_at, task_ends_at).deliver_now

  end

  # Send Crowdfunding Guest Newsletter
  task crowd_campaigns_guest_newsletter: :environment do
    
    scheduled_sending_dates = [
      '2024-11-23', '2024-12-21', '2025-01-18'
    ]

    send_date_today = nil
    send_date_next = nil

    scheduled_sending_dates.each_with_index do |date, index|
      if date.include?(Date.today.to_s)
        send_date_today = date.to_date
        send_date_next = scheduled_sending_dates[index+1].to_date
        break
      end
    end

    if send_date_today

      task_starts_at = Time.now

      crowd_campaigns = CrowdCampaign.guest_newsletter.where(enddate: send_date_today..send_date_next)
      if crowd_campaigns.any?
        CrowdPledge.guest_newsletter_recipients.sort_by(&:created_at).each do |pledge|
          next unless (crowd_campaigns.in(pledge.region).any? || crowd_campaigns.platform.any?)
          CrowdCampaignMailer.crowd_pledge_newsletter(pledge, crowd_campaigns.in(pledge.region).or(crowd_campaigns.platform).map(&:id)).deliver_later
        end
      end

      task_ends_at = Time.now
      AdminMailer.task_info('crowd_campaigns_guest_newsletter', 'finished', task_starts_at, task_ends_at).deliver_now  

    end
    
  end

end
