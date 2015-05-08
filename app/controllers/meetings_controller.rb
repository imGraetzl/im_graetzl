class MeetingsController < ApplicationController
  before_filter :load_graetzl
  before_filter :authenticate_user!, except: [:show]
  before_filter :parse_address_feature, only: [:create, :update]

  @@address

  def show
    @meeting = @graetzl.meetings.find(params[:id])
  end

  def new
    @meeting = @graetzl.meetings.build
    @meeting.build_address
  end

  def edit
    @meeting = @graetzl.meetings.find(params[:id])
  end

  def create
    @meeting = @graetzl.meetings.create(meeting_params)
    @meeting.address = Address.new_from_json_string(params[:feature] || '')
    @meeting.address.description = meeting_params[:address_attributes][:description]
    @meeting.complete_datetimes
    @meeting.remove_cover_photo! if meeting_params[:remove_cover_photo] == '1'

    current_user.go_to(@meeting, GoingTo::ROLES[:initator])
    
    respond_to do |format|
      if @meeting.save
        format.html { redirect_to graetzl_meeting_path(@graetzl, @meeting), notice: 'Neues Treffen wurde erstellt.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @meeting = @graetzl.meetings.find(params[:id])
    @meeting.attributes = meeting_params
    if params[:feature].present?
    #@meeting.update(meeting_params)
      puts "hallo hallo hallo hallo hallo hallo #{params[:feature]}"
      @meeting.address = Address.new_from_json_string(params[:feature])
      @meeting.address.description = meeting_params[:address_attributes][:description]
    end
    @meeting.complete_datetimes
    @meeting.remove_cover_photo! if meeting_params[:remove_cover_photo] == '1'
    puts @meeting.address.street_name

    respond_to do |format|
      #if @meeting.update!(meeting_params)
      if @meeting.save
        format.html { redirect_to [@graetzl, @meeting], notice: 'Meeting was successfully updated.' }
        format.json { render :show, status: :ok, location: @meeting }
      else
        format.html { render :edit }
        format.json { render json: @meeting.errors, status: :unprocessable_entity }
      end
    end
  end

  # def update
    # respond_to do |format|
    #   if @meeting.update(meeting_params)
    #     format.html { redirect_to @meeting, notice: 'Meeting was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @meeting }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @meeting.errors, status: :unprocessable_entity }
    #   end
    # end
  # end

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
        #:feature,
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

    def parse_address_feature
      puts params[:feature]
    end
end
