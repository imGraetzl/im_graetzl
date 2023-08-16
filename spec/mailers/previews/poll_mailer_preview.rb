class PollMailerPreview < ActionMailer::Preview

  def energieteiler_attend_infos
    PollMailer.energieteiler_attend_infos(PollUser.last)
  end

end
