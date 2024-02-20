class Notifications::NewEnergyDemand < Notification
  DEFAULT_INTERVAL = :weekly
  self.class_bitmask = 2**26

  def self.description
    'Eine neue Suche nach einer Einergiegemeinschaft wurde erstellt'
  end

  def mail_subject
    "#{subject.user.username} sucht nach einer Energiegemeinschaft"
  end

  def energy_demand
    subject
  end
end
