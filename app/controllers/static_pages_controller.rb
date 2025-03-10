class StaticPagesController < ApplicationController
  layout :set_layout

  def robots
    render 'robots.text'
  end

  def good_morning_dates
    @category = EventCategory.where("title ILIKE :q", q: "%Good Morning%").last
    @meetings = Meeting.in(current_region).where('starts_at_date > ?', '2025-01-01').joins(:event_categories).where(event_categories: {id: @category&.id})
    @locations = Location.in(current_region).where(meetings: @meetings).distinct
  end

  def balkonsolar
    @category = EventCategory.where("title ILIKE :q", q: "%Balkon%").last
    @meetings = Meeting.in(current_region).joins(:event_categories).where(event_categories: {id: @category&.id})
  end

  def balkonsolar_wien
    @category = EventCategory.where("title ILIKE :q", q: "%Balkon%").last
    @meetings = Meeting.in(current_region).joins(:event_categories).where(event_categories: {id: @category&.id})
  end

  def popup
    @category = EventCategory.where("title ILIKE :q", q: "%WeLocally Pop-Up%").last
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
