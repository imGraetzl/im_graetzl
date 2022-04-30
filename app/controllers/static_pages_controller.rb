class StaticPagesController < ApplicationController
  layout :set_layout

  def robots
    render 'robots.text'
  end

  def good_morning_dates
    @category = EventCategory.find_by_title('Good Morning Dates')
    @meetings = Meeting.in(current_region).joins(:event_categories).where(event_categories: {id: @category.id})
    @locations = Location.in(current_region).where(meetings: @meetings).distinct
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
