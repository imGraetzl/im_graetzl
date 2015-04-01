class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  ## ASSOCIATIONS
  has_one :address, dependent: :destroy
  accepts_nested_attributes_for :address

  belongs_to :graetzl
  accepts_nested_attributes_for :graetzl

  ## ACCESSIBLE / PROTECTED ATTRIBUTES
  attr_accessor :login # virtual attribute to login with username or email

  ## VALIDATIONS
  validates :graetzl, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :terms_and_conditions, acceptance: true

  ## CLASS METHODS
  # overwrite devise authentication method to allow username OR email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).
        where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).
        first
    else
      where(conditions.to_h).first
    end
  end

  ## INSTANCE METHODS
  def autosave_associated_records_for_graetzl
    if new_graetzl = Graetzl.find_by_name(graetzl.name)
      self.graetzl = new_graetzl
    else
      self.graetzl = Graetzl.first
    end
  end

end
