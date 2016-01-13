class Notification < ActiveRecord::Base
  # macros
  belongs_to :user
  belongs_to :activity, :class => PublicActivity::Activity

  # class methods
  def self.receive_new_activity(activity)
    #CreateWebsiteNotificationsJob.perform_later(activity.id)
    CreateWebsiteNotificationsJob.new.async.perform(activity)
  end

  def self.triggered_by?(activity)
    activity.key == self::TRIGGER_KEY
  end

  def self.condition(activity)
    true
  end

  def self.broadcast(activity)
    # TODO use is_triggered_by?(activity) here
    triggered_types = Notification.subclasses.select{ |klass| klass.triggered_by? activity }
    #triggered_types = TYPES.select { |k, v| v[:triggered_by_activity_with_key] == activity.key }
    ids_notified_users =  []
    #sort by bitmask, so that lower order bitmask types are sent first, because
    #higher order bitmask types might not needed to be sent at all, when a user
    #has been already notified via a lower order type.
    # TODO sort by bitmask as class constant here
    triggered_types.sort{|a,b| a::BITMASK <=> b::BITMASK}.each do |klass|
    #triggered_types.keys.sort { |a,b| triggered_types[a][:bitmask] <=> triggered_types[b][:bitmask] }.each do |k|

      # TODO check class condition here...
      if klass.condition(activity)
      #v = triggered_types[k]
      #if v[:condition].nil? || v[:condition].call(activity)
        # TODO receivers as class method
        users = klass.receivers(activity)
        #users = v[:receivers].call(activity)
        #users = users.merge(User.where(["enabled_website_notifications & ? > 0", v[:bitmask]]))
        users.each do |u|
          unless ids_notified_users.include?(u.id) || (u.id == activity.owner.id if activity.owner)
            # TODO add new support for checking if notification enabled
            display_on_website = u.enabled_website_notifications & klass::BITMASK > 0
            #display_on_website = u.enabled_website_notifications & v[:bitmask] > 0
            #n = u.notifications.create(activity: activity, bitmask: v[:bitmask], display_on_website: display_on_website)
            #n = u.notifications.create(activity: activity, bitmask: v[:bitmask], key: k, display_on_website: display_on_website)
            n = klass.create(activity: activity, bitmask: klass::BITMASK, key: 'something', display_on_website: display_on_website, user: u)
            ids_notified_users << u.id if display_on_website
            # if !Rails.env.development? && (u.immediate_mail_notifications & v[:bitmask] > 0)
            #   #SendMailNotificationJob.perform_later(u.id, "immediate", n.id)
            #   SendMailNotificationJob.new.async.perform(u.id, "immediate", n.id)
            #   ids_notified_users << u.id
            # end
          end
        end
      end
    end
  end

  def to_partial_path
    # TODO change this according to behavior
    "notifications/#{key.to_sym}"
  end

  PublicActivity::Activity.after_create do |activity|
    Notification.receive_new_activity(activity)
  end
end
