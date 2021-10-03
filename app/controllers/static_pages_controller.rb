class StaticPagesController < ApplicationController
  layout :set_layout

  def robots
    render 'robots.text'
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
