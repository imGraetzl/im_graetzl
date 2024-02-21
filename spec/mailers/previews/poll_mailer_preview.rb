class PollMailerPreview < ActionMailer::Preview

  def poll_attend_infos
    PollMailer.poll_attend_infos(PollUser.last)
  end

end
