class GroupUser < ApplicationRecord
  include Trackable

  belongs_to :group, counter_cache: true
  belongs_to :user

  enum :role, { member: 0, admin: 1 }

end
