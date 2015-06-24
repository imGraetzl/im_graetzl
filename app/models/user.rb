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

end
