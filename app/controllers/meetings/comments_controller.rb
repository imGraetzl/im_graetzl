class Meetings::CommentsController < CommentsController
  before_action :set_commentable

  private

  def set_commentable
    @commentable = Meeting.find(params[:meeting_id])
  end
end
