class MessengerMailer < ApplicationMailer

  def unseen_messages(user, messages)
    @user = user
    @messages = messages
    @thread = @messages.first.user_message_thread
    @region = @user.region

    headers("X-MC-Tags" => "messenger-mail")

    mail(
      subject: "Du hast neue Nachrichten im Messenger.",
      from: platform_email("no-reply"),
      to: @user.email,
    )
  end

end
