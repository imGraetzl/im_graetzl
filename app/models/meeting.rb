class Meeting < ActiveRecord::Base
  # associations
  has_and_belongs_to_many :graetzls
  has_one :address, as: :addressable, dependent: :destroy
  belongs_to :user_initialized, class_name: 'User'
  has_and_belongs_to_many :users_going, class_name: 'User', join_table: 'meetings_users_going'
end
