class CrowdDonationPledge < ApplicationRecord
  include Trackable
  belongs_to :user, optional: true
  belongs_to :crowd_campaign
  belongs_to :crowd_donation

  enum donation_type: { material: 0, assistance: 1 , room: 2 }

  before_create :set_region_and_type

  validates_presence_of :email, :contact_name

  def email=(val)
    super(val&.strip.presence)
  end

  def contact_name_and_type
    "#{contact_name} (#{email}) | #{I18n.t("activerecord.attributes.crowd_donation.donation_type.#{donation_type}")}"
  end

  def full_name
    contact_name
  end

  private

  def set_region_and_type
    self.region_id = crowd_campaign.region_id
    self.donation_type = crowd_donation.donation_type
  end

end
