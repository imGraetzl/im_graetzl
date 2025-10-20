class GoingTo < ApplicationRecord
  include Trackable
  belongs_to :user
  belongs_to :meeting
  belongs_to :meeting_additional_date, optional: true

  enum :role, { attendee: 0, initiator: 1 }

  def user_width_full_name_and_going_to_date
    if going_to_date
      "#{user.username} | #{user.full_name} (#{display_starts_at_date})"
    else
      "#{user.username} | #{user.full_name}"
    end
  end

  def display_starts_at_date
    if going_to_date && going_to_time
      "#{I18n.localize(going_to_date, format:'%a, %d. %B %Y')}, #{I18n.localize(going_to_time, format:'%H:%M')} Uhr"
    elsif going_to_date
      "#{I18n.localize(going_to_date, format:'%a, %d. %B %Y')}"
    end
  end

end
