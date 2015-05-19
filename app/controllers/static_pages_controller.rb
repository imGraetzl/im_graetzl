class StaticPagesController < ApplicationController
  def welcome
    @user = User.last
  end

  def meetingCreate
  end

  def homeOut
  end

end
