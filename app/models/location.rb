class Location < ActiveRecord::Base
  include Trackable
  extend FriendlyId

  scope :paginate_index, ->(page) { order(id: :desc)
                                      .page(page)
                                      .per(page == 1 ? 1 : 15)
                                      .padding(page == 1 ? 0 : -1) }


  friendly_id :name
  enum state: { pending: 0, approved: 1 }
  enum meeting_permission: { meetable: 0, owner_meetable: 1, non_meetable: 2 }
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image
  acts_as_taggable_on :products

  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  has_many :posts, as: :author, dependent: :destroy, class_name: 'LocationPost'
  accepts_nested_attributes_for :address, allow_destroy: true, reject_if: :all_blank
  has_one :contact, dependent: :destroy
  accepts_nested_attributes_for :contact
  has_many :location_ownerships, dependent: :destroy
  accepts_nested_attributes_for :location_ownerships, allow_destroy: true
  has_many :users, through: :location_ownerships
  belongs_to :category
  has_many :meetings
  has_many :zuckerls, dependent: :destroy
  has_one :billing_address, dependent: :destroy
  accepts_nested_attributes_for :billing_address, allow_destroy: true, reject_if: :all_blank

  validates :name, presence: true
  validates :graetzl, presence: true
  validates :category, presence: true

  def self.meeting_permissions_for_select
    meeting_permissions.map do |t|
      [I18n.t(t[0], scope: [:activerecord, :attributes, :location, :meeting_permissions]), t[0]]
    end
  end

  def approve
    if pending? && approved!
      self.create_activity :approve
      return true
    end
    false
  end

  def reject
    if pending? && destroy
      return true
    end
    false
  end

  def show_meeting_button(user)
    self.meetable? || (self.owner_meetable? && users.include?(user))
  end

  def boss
    location_ownerships.order(:created_at).first.user
  end
end
