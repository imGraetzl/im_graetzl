class MeetingAdditionalDate < ApplicationRecord
  belongs_to :meeting
  has_many :going_tos
  has_many :users, through: :going_tos

  after_update :update_going_tos
  #before_destroy :check_for_going_tos, prepend: true

  #scope :upcoming, -> { where("starts_at_date >= :today", today: Date.today).order(starts_at_date: :asc, starts_at_time: :asc)}
  scope :upcoming, -> { order(starts_at_date: :asc, starts_at_time: :asc)}

  def display_starts_at_date
    if starts_at_time && ends_at_time
      "#{I18n.localize(starts_at_date, format:'%a, %d. %B %Y')}, #{I18n.localize(starts_at_time, format:'%H:%M')} bis #{I18n.localize(ends_at_time, format:'%H:%M')} Uhr"
    elsif starts_at_time
      "#{I18n.localize(starts_at_date, format:'%a, %d. %B %Y')}, #{I18n.localize(starts_at_time, format:'%H:%M')} Uhr"
    else
      "#{I18n.localize(starts_at_date, format:'%a, %d. %B %Y')}"
    end
  end

  private

    def check_for_going_tos
      self.going_tos.update_all(
        going_to_date: nil,
        going_to_time: nil
      )
    end

    def update_going_tos
      #May send Reminder Mail here for existing GoingTos forDate Change ?!
      self.going_tos.update_all(
        going_to_date: self.starts_at_date,
        going_to_time: self.starts_at_time
      )
    end

end
