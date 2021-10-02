class StaticPagesController < ApplicationController

  def robots
    render 'robots.text'
  end

end
