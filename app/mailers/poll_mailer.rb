class PollMailer < ApplicationMailer

  def energieteiler_attend_infos(poll_user)
    @poll_user = poll_user
    @poll = poll_user.poll
    @region = @poll.region

    headers("X-MC-Tags" => "notification-poll-attend-infos")

    mail(
      subject: "Energieteiler: So geht es jetzt weiter",
      from: platform_email('no-reply'),
      to: @poll_user.user.email,
    )
  end

end
