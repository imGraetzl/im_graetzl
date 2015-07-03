class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  attachment :avatar, type: :image

  # associations
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  belongs_to :graetzl
  accepts_nested_attributes_for :graetzl
  has_many :going_tos
  has_many :meetings, through: :going_tos
  has_many :posts
  has_many :comments

  # attributes
    # virtual attribute to login with username or email
    attr_accessor :login
  GENDER_TYPES = { weiblich: 1, männlich: 2, anders: 3 }

  WEBSITE_NOTIFICATION_TYPES = {
    new_meeting_in_graetzl: {
      bitmask: 1,
      describtion: "notify user about a new meeting in the user's graetzl",
      scope: ->(user) do
        PublicActivity::Activity.
          joins("LEFT JOIN meetings m1 ON m1.id = activities.trackable_id
          AND activities.trackable_type = E'Meeting'
          AND m1.graetzl_id = #{user.graetzl_id}").
          where("(m1.id IS NOT NULL OR activities.key <>  E'meeting.create')")
      end
    },
    new_post_in_graetzl: {
      bitmask: 2,
      description: "notify user about a new post in the user's graetzl",
      scope: ->(user) do
        PublicActivity::Activity.
          joins("LEFT JOIN posts p1 ON p1.id = activities.trackable_id
          AND activities.trackable_type = E'Post'
          AND p1.graetzl_id = #{user.graetzl_id}").
          where("(p1.id IS NOT NULL OR activities.key <>  E'post.create')")
      end
    },
    update_of_meeting: {
      bitmask: 4,
      description: "notify if a meeting that the user attends has been updated",
      scope: ->(user) do
        PublicActivity::Activity.
          joins("LEFT JOIN meetings m2 ON m2.id = activities.trackable_id
             AND activities.trackable_type = E'Meeting'
             AND activities.key = E'meeting.update'
             LEFT JOIN going_tos gt1 ON gt1.meeting_id = m2.id
             AND gt1.user_id = #{user.id}").
          where("(gt1.id IS NOT NULL OR m2.id IS NULL)") 
      end
    },
    organizer_comments: {
      bitmask: 8,
      description: "notify if orgainzer comments a meeting that user attends",
      scope: ->(user) do
        PublicActivity::Activity.
          joins("LEFT JOIN comments c1 ON c1.id = activities.trackable_id
            AND activities.trackable_type = E'Comment'
            AND c1.commentable_type = E'Meeting'
            LEFT JOIN meetings m3 ON
            m3.id = c1.commentable_id
            LEFT JOIN going_tos gt2 ON
            gt2.meeting_id = m3.id
            AND gt2.role = #{GoingTo::ROLES[:initiator]}
            LEFT JOIN going_tos gt3 ON
            gt3.meeting_id = gt2.meeting_id
            AND gt3.user_id = #{user.id}").
          where("(gt3.id IS NOT NULL AND
            gt2.id IS NOT NULL)
            OR m3.id IS NULL")
      end
    },
    another_user_comments: {
      bitmask: 16,
      description: "notify if another user comments a meeting that the user attends",
      scope: ->(user) do
        PublicActivity::Activity.
          joins("LEFT JOIN comments c2 ON c2.id = activities.trackable_id
            AND activities.trackable_type = E'Comment'
            AND c2.commentable_type = E'Meeting'
            LEFT JOIN meetings m4 ON
            m4.id = c2.commentable_id
            LEFT JOIN going_tos gt4 ON
            gt4.meeting_id = m4.id
            AND gt4.user_id = #{user.id}").
          where("gt4.id IS NOT NULL
            OR m4.id IS NULL")
      end
    },
    another_attendee: {
      bitmask: 32,
      description: "notify if another user attends the meeting created by the user",
      scope: ->(user) do
        PublicActivity::Activity.
          joins("LEFT JOIN going_tos gt5 ON
            gt5.id = activities.trackable_id
            AND activities.trackable_type = E'GoingTo'
            AND gt5.role = #{GoingTo::ROLES[:attendee]}
            LEFT JOIN going_tos gt6  ON
            gt6.meeting_id = gt5.meeting_id
            AND gt6.user_id = #{user.id}
            AND gt6.role = #{GoingTo::ROLES[:initiator]}").
          where("gt6.id IS NOT NULL
            OR gt5.id IS NULL")
      end
    }
  }

  # validations
  validates :graetzl, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :terms_and_conditions, acceptance: true
  #validates_integrity_of :avatar
  #validates_processing_of :avatar

  # class methods
  # overwrite devise authentication method to allow username OR email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).
        where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).
        first
    else
      where(conditions.to_h).first
    end
  end

  # instance methods
  def autosave_associated_records_for_graetzl
    if new_graetzl = Graetzl.find_by_name(graetzl.name)
      self.graetzl = new_graetzl
    else
      self.graetzl = Graetzl.first
    end
  end

  def going_to?(meeting)
    meetings.include?(meeting)
  end

  def initiated?(meeting)
    going_to = going_tos.find_by_meeting_id(meeting)
    going_to && going_to.role == GoingTo::ROLES[:initiator]
  end

  def go_to(meeting, role=GoingTo::ROLES[:attendee])
    going_tos.create(meeting_id: meeting.id, role: role)
  end

  def enabled_website_notification?(type)
    enabled_website_notifications & WEBSITE_NOTIFICATION_TYPES[type][:bitmask] > 0
  end

  def enable_website_notification(type)
    new_setting = enabled_website_notifications | WEBSITE_NOTIFICATION_TYPES[type][:bitmask] 
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def toggle_website_notification(type)
    new_setting = enabled_website_notifications ^ WEBSITE_NOTIFICATION_TYPES[type][:bitmask] 
    update_attribute(:enabled_website_notifications, new_setting)
  end

  def website_notifications
    return PublicActivity::Activity.where("1 <> 1") if enabled_website_notifications == 0

    scope = PublicActivity::Activity.where(["owner_id <> :id", id: self.id])
    WEBSITE_NOTIFICATION_TYPES.keys.each do |type|
      if enabled_website_notification?(type)
        scope = scope.merge(WEBSITE_NOTIFICATION_TYPES[type][:scope].call(self))
      end
    end
    scope
  end

  def new_website_notifications_count
    unless website_notifications_last_checked.nil?
      website_notifications.where(["created_at > ?", website_notifications_last_checked]).count
    else
      website_notifications.count
    end
  end
end
