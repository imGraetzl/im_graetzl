class Users::ZuckerlsController < ApplicationController
  before_action :authenticate_user!

  def index
    @zuckerls = Zuckerl.where(location: current_user.locations)
  end
end
