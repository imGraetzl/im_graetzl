class Graetzls::MeetingsController < MeetingsController
  def index
    @meetings = @graetzl.meetings.by_currentness.includes(:graetzl, :location)
    @meetings = @meetings.page(params[:page]).per(15)
  end

  def show
    @meeting = find_meeting
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
