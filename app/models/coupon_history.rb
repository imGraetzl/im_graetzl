class CouponHistory < ApplicationRecord
  belongs_to :user
  belongs_to :coupon, optional: true    # Referenz auf Coupon, kann leer sein

  scope :valid, -> { where('valid_until >= ?', Time.current) }
  scope :expired, -> { where('valid_until < ?', Time.current) }
  scope :redeemed, -> { where.not(redeemed_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }

  def to_s
    user
  end

end
