namespace :scheduled do
  desc 'Set new startDate if in past and additional future Date exists'
  task update_meeting_date: :environment do

    # Delete all PAST Additonal Dates
    MeetingAdditionalDate.where('starts_at_date < ?', Date.today).each do |model|
      model.destroy
    end

    # Find all Meetings where Start Date = Yesterday
    # Look if they have Additonal Dates in Future
    # Set new startDate for Meeting
    # Delete next Additonal Date
    # Update Activity if previous Activity of this Meeting is more then 1 Week ago
    Meeting.where("starts_at_date = ?", Date.yesterday).find_each do |meeting|
      if meeting.meeting_additional_dates.present?
        meeting.activate_next_date!
        Rails.logger.info("[Meeting] Meeting (#{meeting.id}) updated next meeting date: #{meeting.starts_at_date}")
        # Update Activity if there is none in the last week
        if !Activity.where(subject: meeting).where("created_at >= ?", 1.week.ago).exists?
          ActionProcessor.track(meeting, :create)
        end
      elsif meeting.online_meeting?
        # Destroy old "create.meeting" Activities for online meetings if no Additonal Dates present (lets stay offline meetings for now)
        Activity.where(subject: meeting).destroy_all
      end

    end

  end

  desc 'Send Info Mail to Upcoming Meetings without Category'
  task info_mail_missing_meeting_category: :environment do
    user_id = nil
    Meeting.upcoming.includes(:event_categories).where(event_categories: {id: nil}).find_each do |meeting|
      next if user_id == meeting.user.id
      MeetingMailer.missing_meeting_category(meeting).deliver_now
      user_id = meeting.user.id
    end
  end

end
