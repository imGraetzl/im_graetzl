class GroupMailer < ApplicationMailer

  def group_online(group, user)
    @group = group
    @user = user
    @region = @group.region

    headers("X-MC-Tags" => "notification-group-online")

    mail(
      subject: "Deine Gruppe ist nun online.",
      from: platform_email("no-reply"),
      to: user.email,
    )
  end

  def new_join_request(join_request, user)
    @join_request = join_request
    @user = user
    @region = @join_request.group.region

    headers("X-MC-Tags" => "group-new-join-request")

    mail(
      subject: "Neue Beitrittsanfrage für deine Gruppe.",
      from: platform_email("no-reply"),
      to: user.email,
    )
  end

  def join_request_accepted(group, user)
    @group = group
    @user = user
    @region = @group.region

    headers("X-MC-Tags" => "group-new-member")

    mail(
      subject: "Deine Beitrittsanfrage zur Gruppe wurde bestätigt.",
      from: platform_email("no-reply"),
      to: user.email,
    )
  end

  def message_to_user(group, from_user, to_user, subject, message)
    @group, @user, @message = group, from_user, message
    @region = @group.region
    @reply_email = from_user.email

    headers(
      "X-MC-Tags" => "group-user-mail",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "group-user-mail",
    )

    mail(
      subject: subject,
      to: to_user.email,
      from: "#{from_user.full_name} | über #{platform_email('no-reply')}>",
      reply_to: @reply_email,
    )
  end

end
