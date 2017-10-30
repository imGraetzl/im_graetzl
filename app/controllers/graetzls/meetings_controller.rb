class Graetzls::MeetingsController < MeetingsController
  def show
    @graetzl = find_graetzl
    @meeting = @graetzl.meetings.includes(going_tos: :user).find(params[:id])
    verify_graetzl_child(@meeting) unless request.xhr?
    @comments = @meeting.comments.includes(:user, :images).order(created_at: :desc)
      .page(params[:page]).per(10)
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

  def verify_graetzl_child(child)
    redirect_to [child.graetzl, child] if @graetzl != child.graetzl
  end
end
