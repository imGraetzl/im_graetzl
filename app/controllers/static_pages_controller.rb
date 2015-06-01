class StaticPagesController < ApplicationController

  def home
    if user_signed_in?
      redirect_to current_user.graetzl
    end    
  end

  def meetingCreate
  end

  def homeOut
  end

end
