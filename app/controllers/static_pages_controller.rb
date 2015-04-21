class StaticPagesController < ApplicationController
  def welcome
    @user = User.last
  end

  def treffenAnlegen
  end

end
