class UserMessageThread < ApplicationRecord
  has_many :user_message_thread_members, dependent: :destroy
  has_many :users, through: :user_message_thread_members
  has_many :user_messages, dependent: :destroy

  belongs_to :room_rental, optional: true

  enum thread_type: { general: 0, room_rental: 1 }

  before_create :set_last_message_at

  attr_accessor :status

  def self.create_for_room_rental(room_rental)
    thread = find_by(room_rental_id: room_rental.id)
    return thread if thread
    thread = create(room_rental: room_rental, thread_type: :room_rental)
    thread.users << room_rental.renter
    thread.users << room_rental.owner
    thread
  end

  def self.create_general(*users)
    user_key = users.map(&:id).sort.join(":")
    thread = find_by(user_key: user_key)
    return thread if thread
    thread = create(user_key: user_key, thread_type: :general)
    thread.users = users
    thread
  end

  private

  def set_last_message_at
    self.last_message_at = Time.current
  end
end
