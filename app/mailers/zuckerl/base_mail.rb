class Zuckerl::BaseMail
  include MailUtils

  def initialize(zuckerl)
    @zuckerl = zuckerl
    @location = zuckerl.location
    @user = @location.boss
  end

  def deliver
    MandrillMailer.deliver template: template, message: message
  end

  private

  attr_reader :zuckerl, :location, :user

  def template
    raise NotImplementedError, "template not implemented for #{self.class}"
  end

  def message
    raise NotImplementedError, "build_message not implemented for #{self.class}"
  end
end
