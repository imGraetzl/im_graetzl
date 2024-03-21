class MeetingMailer < ApplicationMailer

  def message_to_user(meeting, from_user, to_user, subject, message)
    @meeting, @user, @message = meeting, from_user, message
    @region = @meeting.region
    @reply_email = from_user.email
    @sender_email = email_address_with_name("no-reply@#{@region.host_domain}", "#{from_user.full_name} | über #{@region.host_domain_name}")

    headers(
      "X-MC-Tags" => "meeting-user-mail",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "meeting-user-mail",
    )

    mail(
      subject: subject,
      to: to_user.email,
      from: @sender_email,
      reply_to: @reply_email,
    )
  end

  def create_meeting_reminder(meeting)
    @meeting = meeting
    @region = @meeting.region
    headers(
      "X-MC-Tags" => "create-meeting-reminder",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "create-meeting-reminder",
    )
    mail(
      to: @meeting.user.email,
      from: platform_email('no-reply'),
      subject: "Hast du wieder ein Event oder ein Treffen in Planung?")
  end

  def good_morning_date_invite(user, meeting)
    @user = user
    @meeting = meeting
    @district = @meeting.graetzl.district
    @region = @meeting.region
    headers(
      "X-MC-Tags" => "good-morning-date-invite",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "good-morning-date-invite",
    )
    mail(
      to: @user.email,
      from: platform_email("wir", "Mirjam"),
      subject: "Vernetzung im #{@district.numeric}. Bezirk, komm doch auch zum Good Morning Date am #{I18n.localize(@meeting.starts_at_date, format:'%d. %B')}")
  end

end
