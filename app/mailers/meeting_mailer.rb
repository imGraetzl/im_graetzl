class MeetingMailer < ApplicationMailer

  def message_to_user(meeting, from_user, to_user, subject, message, from_email_name)
    @meeting, @user, @message = meeting, from_user, message
    @region = @meeting.region

    if from_email_name.present?
      @reply_email = "#{from_email_name}@#{@region.email_host}"
    else
      @reply_email = from_user.email
    end

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
