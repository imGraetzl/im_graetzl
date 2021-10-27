class Notifications::NewToolDemand < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**19

  def self.description
    'Eine neue Toolsuche wurde veröffentlicht'
  end

  def mail_subject
    "Es gibt eine neue Toolsuche"
  end

  def tool_demand
    subject
  end
end
