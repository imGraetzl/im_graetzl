class MeetingsController < ApplicationController
  before_filter :set_graetzl
  before_filter :set_meeting, except: [:index, :new, :create]
  before_filter :authenticate_user!, except: [:show, :index]
  before_filter :check_permission!, only: [:edit, :update, :destroy]

  def index
    @meetings = @graetzl.meetings
  end

  def show
  end

  def new
    @meeting = @graetzl.meetings.build
    @meeting.build_address
  end

  def create
    @meeting = @graetzl.meetings.create(meeting_params)
    @meeting.graetzl = @meeting.address.graetzl || @graetzl
    current_user.go_to(@meeting, GoingTo::ROLES[:initiator])
    
    if @meeting.save
      @meeting.create_activity :create, owner: current_user
      redirect_to [@meeting.graetzl, @meeting], notice: 'Neues Treffen wurde erstellt.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @meeting.attributes = meeting_params
    @meeting.graetzl = @meeting.address.graetzl if @meeting.address.graetzl
    #@meeting.remove_cover_photo! if meeting_params[:remove_cover_photo] == '1'

    if @meeting.save
      redirect_to [@meeting.graetzl, @meeting], notice: "Treffen #{@meeting.name} wurde aktualisiert."
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
      if params[:address].present? && params[:feature].blank?
        meeting_params_basic
      else
        meeting_params_basic.deep_merge(address_attributes: address_attr)
      end
    end

    def meeting_params_basic
      params.
        require(:meeting).
        permit(:name,
          :description,
          :starts_at_date, :starts_at_time,
          :ends_at_time,
          :cover_photo,
          :remove_cover_photo,
          :cover_photo_cache,
          :remove_cover_photo,
          category_ids: [],
          address_attributes: [:id, :description])      
    end

    def address_attr
      Address.attributes_from_feature(params[:feature]) || Address.attributes_to_reset_location
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
end
