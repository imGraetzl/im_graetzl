class StaticPagesController < ApplicationController
  layout :set_layout

  def robots
    render 'robots.text'
  end

  def energie_teiler
  end

  def good_morning_dates
    @category = EventCategory.where("title ILIKE :q", q: "%Good Morning%").last
    @meetings = Meeting.in(current_region).joins(:event_categories).where(event_categories: {id: @category.id})
    @locations = Location.in(current_region).where(meetings: @meetings).distinct
  end

  def balkonsolar
    @category = EventCategory.where("title ILIKE :q", q: "%Balkon%").last
    @meetings = Meeting.in(current_region).joins(:event_categories).where(event_categories: {id: @category.id})
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
