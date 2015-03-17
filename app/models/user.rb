class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # validations
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  # virtual attribute to login with either username or password
  attr_accessor :login

  # registration step
  attr_writer :registration_step

  def registration_step
    @registration_step || registration_steps.first
  end

  def registration_steps
    %w[address choose_location personal_data]
  end

  def next_registration_step
    self.registration_step = registration_steps[registration_steps.index(registration_step) + 1]
  end

  def previous_registration_step
    self.registration_step = registration_steps[registration_steps.index(registration_step) - 1]
  end

  def first_step?
    registration_step == registration_steps.first
  end

  def last_step?
    registration_step == registration_steps.last
  end

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
end
