class Notifications::NewCoopDemand < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**23

  def self.description
    'Ein neues Coop & Share Angebot wurde veröffentlicht'
  end

  def mail_subject
    "Es gibt ein neues Coop & Share Angebot."
  end

  def coop_demand
    subject
  end

  def self.immediate_option_enabled?
    false
  end
  
end
