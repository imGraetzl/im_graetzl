class PollUsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_poll

  def new
    render 'polls/show'
  end

  def create

    if @poll.users.include?(current_user)
      
      poll_user = @poll.poll_users.where(user: current_user).last
      flash.now[:notice] = "Du hast bereits teilgenommen."
      render 'polls/show'

    else

      @poll_user = @poll.poll_users.build(poll_user_params)
      @poll_user.user = current_user
    
      if @poll_user.save
        ActionProcessor.track(@poll_user, :create)
        redirect_to @poll
      else
        redirect_to @poll
      end

    end
    
  end

  private

  def set_poll
    @poll = Poll.find(params[:poll_id])
  end

  def poll_user_params
    params.require(:poll_user).permit(
      :poll_user_answer,
      poll_user_answers_attributes: [
        :id, :poll_question_id, :poll_option_id, :answer, :_destroy
      ]
    )
  end

end
