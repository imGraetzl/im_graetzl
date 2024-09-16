class Notifications::NewToolDemand < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**19

  def self.description
    'Eine neue Gerätesuche wurde veröffentlicht'
  end

  def mail_subject
    "Es gibt eine neue Gerätesuche"
  end

  def tool_demand
    subject
  end

  def self.immediate_option_enabled?
    false
  end

end
