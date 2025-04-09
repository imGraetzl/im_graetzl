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

    # Send Reminder email to failed Pledges after X Days
    CrowdCampaign.completed.where(enddate: 3.days.ago).find_each do |campaign|
      campaign.crowd_pledges.failed.find_each do |pledge|
        CrowdCampaignMailer.crowd_pledge_failed_reminder(pledge).deliver_later
      end
    end

    if Date.today.monday?
      wednesday = Date.today + 2  # Übermorgen (Mittwoch)
      next_tuesday = wednesday + 6 # Dienstag in einer Woche
    
      CrowdCampaign.ending_newsletter.where(enddate: wednesday..next_tuesday).find_each do |campaign|
        ActionProcessor.track(campaign, :ending)
      end
    end

    task_ends_at = Time.now
    #AdminMailer.task_info('crowd_campaigns_upkeep', 'finished', task_starts_at, task_ends_at).deliver_now

  end

  # Send Crowdfunding Guest Newsletter
  task crowd_campaigns_guest_newsletter: :environment do
    
    scheduled_sending_dates = [
      '2025-03-22', '2025-04-19'
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
      #AdminMailer.task_info('crowd_campaigns_guest_newsletter', 'finished', task_starts_at, task_ends_at).deliver_now  

    end
    
  end

  task ending_campaign_reminders: :environment do
    tomorrow = Date.tomorrow
    cutoff_time = 24.hours.ago
    campaigns = CrowdCampaign.incomplete_newsletter.where(enddate: tomorrow)

    Rails.logger.info("[Ending Campaign Reminder]: Ending Incomplete Newlsetter Campaigns tomorrow: #{campaigns.count}")

    campaigns.find_each do |campaign|

      # Step 1: User mit `incomplete` älter als 24h
      incomplete_user_ids = CrowdPledge.where(crowd_campaign_id: campaign.id)
                                        .incomplete
                                        .where('created_at < ?', cutoff_time)
                                        .pluck(:user_id)
                                        .uniq

      # Step 2: User mit `initialized` pledges
      initialized_user_ids = CrowdPledge.where(crowd_campaign_id: campaign.id)
                                        .initialized
                                        .pluck(:user_id)
                                        .uniq

      # Step 3: Nur relevante Nutzer (incomplete & nicht initialized)
      user_ids_to_notify = incomplete_user_ids - initialized_user_ids

      User.where(id: user_ids_to_notify).find_each do |user|
        CrowdCampaignMailer.ending_campaign_incomplete_reminder(user, campaign).deliver_later
        Rails.logger.info("[Ending Campaign Reminder]: Campaign-ID: #{campaign.id}: #{user.email} reminded")
      end

      Rails.logger.info("[Ending Campaign Reminder]: Campaign-ID: #{campaign.id}: #{user_ids_to_notify.count} total Users reminded")

    end

  end

end
