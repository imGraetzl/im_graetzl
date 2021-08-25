class AdminMailer < ApplicationMailer
  default from: 'Info imGrätzl.at <no-reply@imgraetzl.at>'
  default to: 'wir@imgraetzl.at'

  def new_zuckerl(zuckerl)
    @zuckerl = zuckerl
    @location = @zuckerl.location
    mail(subject: "[ImGrätzl] Buchung Zuckerl von #{@location.name}")
  end

  def new_paid_going_to(going_to)
    @going_to = going_to
    @meeting = @going_to.meeting
    mail(subject: "[ImGrätzl] Ticket-Kauf für #{@meeting.name}")
  end

end
