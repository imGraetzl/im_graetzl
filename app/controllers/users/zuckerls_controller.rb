class Users::ZuckerlsController < ApplicationController
  before_action :authenticate_user!

  def index
    @zuckerls = Zuckerl.where(location: current_user.locations).
      where.not(aasm_state: :cancelled)
  end
end
