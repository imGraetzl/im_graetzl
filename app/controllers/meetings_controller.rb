class MeetingsController < ApplicationController
  before_filter :load_graetzl
  before_filter :authenticate_user!, except: [:show]

  def show
    @meeting = @graetzl.meetings.find(params[:id])
  end

  def new
    @meeting = @graetzl.meetings.build
    @meeting.build_address
  end

  def create
    @meeting = @graetzl.meetings.create(meeting_params)
    merge_changes
    current_user.go_to(@meeting, GoingTo::ROLES[:initator])
    
    respond_to do |format|
      if @meeting.save
        format.html { redirect_to graetzl_meeting_path(@graetzl, @meeting), notice: 'Neues Treffen wurde erstellt.' }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @meeting = @graetzl.meetings.find(params[:id])
  end

  def update
    @meeting = @graetzl.meetings.find(params[:id])
    @meeting.attributes = meeting_params
    merge_changes

    respond_to do |format|
      if @meeting.save
        format.html { redirect_to [@graetzl, @meeting], notice: "Treffen #{@meeting.name} wurde aktualisiert." }
      else
        format.html { render :edit }
      end
    end
  end

  # def destroy
  #   @meeting.destroy
  #   respond_to do |format|
  #     format.html { redirect_to meetings_url, notice: 'Meeting was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

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
        address_attributes: [:description])
    end

    def load_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end

    def merge_changes
      if params[:feature].present?
        new_address_attrs = Address.new_from_json_string(params[:feature]).attributes
        @meeting.address.merge_feature(new_address_attrs)
      end
      @meeting.complete_datetimes
      @meeting.remove_cover_photo! if meeting_params[:remove_cover_photo] == '1'
    end
end
