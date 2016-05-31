class Graetzls::MeetingsController < MeetingsController
  def index
    # @graetzl = find_graetzl
    @meetings = @graetzl.meetings.
      by_currentness.
      page(params[:page]).per(15)
  end

  def show
    # @graetzl = find_graetzl
    verify_graetzl_child(@meeting) unless request.xhr?
    @comments = @meeting.comments.
      order(created_at: :desc).
      page(params[:page]).per(10)
  end

  def new
    @parent = find_graetzl
    @meeting = @parent.build_meeting
  end

  def create
    @parent = find_graetzl
    super
  end

  private

  def find_graetzl
    Graetzl.find params[:graetzl_id]
  end
end
