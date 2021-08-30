class RoomCall < ApplicationRecord
  include Trackable
  include Address

  extend FriendlyId
  friendly_id :title

  belongs_to :user
  belongs_to :graetzl
  belongs_to :district

  has_many :room_call_fields
  accepts_nested_attributes_for :room_call_fields, allow_destroy: true, reject_if: :all_blank
  has_many :room_call_submissions

  has_many :room_call_modules
  has_many :room_modules, through: :room_call_modules
  accepts_nested_attributes_for :room_call_modules, allow_destroy: true, reject_if: proc { |attrs| attrs['room_module_id'].blank? }

  has_many :room_call_prices
  accepts_nested_attributes_for :room_call_prices, allow_destroy: true, reject_if: :all_blank

  belongs_to :location, optional: true

  include AvatarUploader::Attachment(:avatar)
  include CoverImageUploader::Attachment(:cover_photo)

  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  has_one :group

  validates_presence_of :address_street, :title, :starts_at, :ends_at, :opens_at, :description, :about_us, :about_partner,
  :cover_photo, :first_name, :last_name, :email, :room_call_fields

  after_create :set_group

  scope :open_calls, -> { where("starts_at <= current_date AND ends_at >= current_date") }

  def to_s
    title
  end

  def open?
    (starts_at..ends_at).cover?(Date.current)
  end

  def graetzl=(value)
    super
    self.district ||= value.district if value.present?
  end

  private

  def set_group
    group = build_group(
      title: "#{title} Gruppe",
      description: description,
      graetzls: [graetzl],
    )
    group.cover_photo_attacher.set group.cover_photo_attacher.upload(cover_photo_attacher.file)
    group.cover_photo_attacher.add_derivatives cover_photo_attacher.derivatives
    group.save!
    group.group_users.create(user_id: user_id, role: :admin)
  end

end
