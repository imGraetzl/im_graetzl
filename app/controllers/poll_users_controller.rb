class PollUsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_poll

  def new
    render 'polls/show'
  end

  def create

    if @poll.poll_users.exists?(user_id: current_user.id)
      
      flash.now[:notice] = "Du hast bereits teilgenommen."
      render 'polls/show'

    elsif @poll.closed?

      flash.now[:notice] = "Diese Umfrage ist schon geschlossen."
      render 'polls/show'

    else

      @poll_user = @poll.poll_users.build(poll_user_params)
      @poll_user.user = current_user
    
      if @poll_user.save
        ActionProcessor.track(@poll_user, :create)

        # Create Comment id User permitted!
        if @poll_user.poll_user_answers.public_comment.present?
          @comment = @poll.comments.new(user_id: current_user.id, content: @poll_user.poll_user_answers.public_comment.last.answer)
          if @comment.save
            ActionProcessor.track(@comment.commentable, :comment, @comment)
          end
        end

        #PollMailer.poll_attend_infos(@poll_user).deliver_later
        flash[:success] = "Vielen Dank für deine Teilnahme."
        
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
        :id, :poll_question_id, :poll_option_id, :answer, :public_comment, :_destroy
      ]
    )
  end

end
