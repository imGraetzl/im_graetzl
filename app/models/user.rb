class User < ActiveRecord::Base
  has_one :address, dependent: :destroy
  accepts_nested_attributes_for :address

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # virtual attribute to login with username or email
  attr_accessor :login

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :terms_and_conditions, acceptance: true


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
