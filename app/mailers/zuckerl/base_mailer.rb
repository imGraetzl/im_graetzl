class Zuckerl::BaseMailer < MandrillMailer
  def initialize(zuckerl)
    @zuckerl = zuckerl
    @location = zuckerl.location
    @user = @location.boss
    super template: MAIL_TEMPLATE, message: build_message
  end

  private

  attr_reader :zuckerl, :location, :user

  def build_message
    raise NotImplementedError, "build_message not implemented for #{self.class}"
  end

  def message_vars
    raise NotImplementedError, "message_vars not implemented for #{self.class}"
  end
end
