class AdminMailer < ApplicationMailer
  default from: 'Info imGrätzl.at <no-reply@imgraetzl.at>'
  default to: 'wir@imgraetzl.at'

  def new_zuckerl(zuckerl)
    @zuckerl = zuckerl
    @location = @zuckerl.location
    mail(subject: "[ImGrätzl] Buchung Grätzlzuckerl von #{@location.name}")
  end
end
