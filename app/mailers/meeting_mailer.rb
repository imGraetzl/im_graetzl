class MeetingMailer < ApplicationMailer

  def message_to_user(meeting, from_user, to_user, subject, message)
    @meeting, @user, @message = meeting, from_user, message
    @region = @meeting.region
    @reply_email = from_user.email

    headers(
      "X-MC-Tags" => "meeting-user-mail",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "meeting-user-mail",
    )

    mail(
      subject: subject,
      to: to_user.email,
      from: "#{from_user.full_name} | über #{platform_email('no-reply')}>",
      reply_to: @reply_email,
    )
  end

  def create_meeting_reminder(meeting)
    @meeting = meeting
    headers(
      "X-MC-Tags" => "create-meeting-reminder",
      "X-MC-GoogleAnalytics" => 'staging.imgraetzl.at, www.imgraetzl.at',
      "X-MC-GoogleAnalyticsCampaign" => "create-meeting-reminder",
    )
    mail(to: @meeting.user.email, subject: "Hast du wieder ein Event oder ein Treffen in Planung?")
  end

  def missing_meeting_category(meeting)
    @meeting = meeting
    @region = @meeting.region

    headers(
      "X-MC-Tags" => "info-mail-missing-meeting-category",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "info-mail-missing-meeting-category",
    )
    mail(
      subject: "Kategorie zuweisen für '#{@meeting.name}'",
      from: platform_email('no-reply'),
      to: @meeting.user.email,
    )
  end

end
