class GroupMailer < ApplicationMailer

  def group_online(group, user)
    @group = group
    @user = user
    mail(to: user.email, subject: "Deine Gruppe ist nun online.")
  end

  def new_join_request(join_request, user)
    @join_request = join_request
    @user = user
    mail(to: user.email, subject: "Neue Beitrittsanfrage für deine Gruppe.")
  end

  def join_request_accepted(group, user)
    @group = group
    @user = user

    headers("X-MC-Tags" => "group-new-member")
    mail(to: user.email, subject: "Deine Beitrittsanfrage zur Gruppe wurde bestätigt.")
  end

  def message_to_user(group, from_user, to_user, subject, message, from_email)
    @group, @user, @message = group, from_user, message
    reply_to = from_email.present? ? "#{from_email}@imgraetzl.at" : from_user.email
    from_email = from_email.present? ? "#{from_email}@imgraetzl.at" : "no-reply@imgraetzl.at"

    html_body = body.gsub("\r\n", "<br/>")

    headers(
      "X-MC-Tags" => "group-user-mail",
      "X-MC-GoogleAnalytics" => 'staging.imgraetzl.at, www.imgraetzl.at',
      "X-MC-GoogleAnalyticsCampaign" => "group-user-mail",
    )
    mail(
      to: to_user.email, from: "#{from_user} | imGrätzl.at <#{from_email}>",
      reply_to: reply_to, subject: subject
    )
        { name: 'email_body', content: html_body },
        { name: 'group_name', content: group.title },
        { name: 'group_url', content: group_url(group, URL_OPTIONS) },
        { name: 'from_name', content: user.full_name },
        { name: 'from_email', content: from_email },
        { name: 'reply_to_email', content: reply_to },
        { name: 'user_avatar_url', content: Notifications::ImageService.new.avatar_url(user) }
      ]
    })
  end

end
