class MeetingsController < ApplicationController
  before_filter :set_graetzl
  before_filter :set_meeting, except: [:index, :new, :create]
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :check_permission!, only: [:edit, :update, :destroy]

  def index
    @meetings = @graetzl.meetings
    @meetings_past = @meetings.where('starts_at_date < ?', Date.today)
    @meetings_current = @meetings.where.not(id: @meetings_past.pluck(:id))
  end

  def show
  end

  def new
    @meeting = @graetzl.meetings.build
    @meeting.build_address
  end

  def create
    @meeting = @graetzl.meetings.create(meeting_params)
    merge_changes
    current_user.go_to(@meeting, GoingTo::ROLES[:initiator])
    
    if @meeting.save
      @meeting.create_activity :create, owner: current_user
      redirect_to [@graetzl, @meeting], notice: 'Neues Treffen wurde erstellt.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @meeting.attributes = meeting_params
    merge_changes

    if @meeting.save
      redirect_to [@graetzl, @meeting], notice: "Treffen #{@meeting.name} wurde aktualisiert."
    else
      render :edit
    end
  end

  def destroy
    @meeting.destroy
    redirect_to @graetzl, notice: 'Treffen abgesagt.'
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def meeting_params
      params.require(:meeting).permit(:name,
        :description,
        :starts_at_date, :starts_at_time,
        :ends_at_time,
        :cover_photo,
        :cover_photo_cache,
        :remove_cover_photo,
        category_ids: [],
        address_attributes: [:id, :description])
    end

    def set_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end

    def set_meeting
      @meeting = @graetzl.meetings.find(params[:id])
    end

    def check_permission!
      unless current_user.initiated?(@meeting)
        redirect_to [@graetzl, @meeting], notice: 'Keine Rechte.'
      end
    end

    def merge_changes
      if params[:feature].present? || (params[:address].blank? && @meeting.address.present?)
        new_address_attrs = Address.new_from_json_string(params[:feature]).attributes
        @meeting.address.merge_feature(new_address_attrs)
      end
      @meeting.remove_cover_photo! if meeting_params[:remove_cover_photo] == '1'
    end
end
