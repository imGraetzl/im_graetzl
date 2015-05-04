class StaticPagesController < ApplicationController
  def welcome
    @user = User.last
  end

  def meetingCreate
  end

end
