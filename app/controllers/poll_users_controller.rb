class PollUsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_poll

  def new
    render 'polls/show'
  end

  def create

    @poll_user = @poll.poll_users.build(poll_user_params)
    @poll_user.user = current_user

    if @poll_user.save
      redirect_to @poll
    else
      redirect_to @poll
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
