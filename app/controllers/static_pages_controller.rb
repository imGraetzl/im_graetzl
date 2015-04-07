class StaticPagesController < ApplicationController
  def welcome
    @user = User.last
  end
end
