class StaticPagesController < ApplicationController
  layout :set_layout

  def robots
    render formats: [:text]
  end

  def good_morning_dates
    @category = EventCategory.find_by!(slug: 'good-morning-dates')
    @meetings = Meeting.good_morning_dates.in(current_region).where('starts_at_date > ?', '2025-01-01')
    @locations = Location.in(current_region).where(meetings: @meetings).distinct
  end

  def balkonsolar
    @category = EventCategory.find_by!(slug: 'balkon-solar')
    @meetings = Meeting.in(current_region).joins(:event_categories).where(event_categories: {id: @category&.id})
  end

  def balkonsolar_wien
    @category = EventCategory.find_by!(slug: 'balkon-solar')
    @meetings = Meeting.in(current_region).joins(:event_categories).where(event_categories: {id: @category&.id})
  end

  private

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

end
