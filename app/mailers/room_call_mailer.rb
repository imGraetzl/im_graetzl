class RoomCallMailer < ApplicationMailer

  def notify_submitter(room_call_submission)
    @submission = room_call_submission
    @region = @submission.room_call.region

    headers("X-MC-Tags" => "room-call-submission")

    mail(
      subject: "Danke für deine Teilnahme! Die ersten Infos für dich ...",
      from: platform_email('no-reply'),
      to: @submission.user.email,
    )
  end

  def notify_owner(room_call_submission)
    @submission = room_call_submission
    @region = @submission.room_call.region

    mail(
      subject: "Neue Call Bewerbung.",
      from: platform_email('no-reply'),
      to: @submission.room_call.user.email,
      bcc: 'call@imgraetzl.at',
    )
  end

end
