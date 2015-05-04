class MeetingsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]

  def show
    @graetzl = Graetzl.find(params[:graetzl_id])
    @meeting = Meeting.find(params[:id])
  end

  def new
    @meeting = current_user.meetings_initialized.build
    @graetzl = Graetzl.find(params[:graetzl_id])

    @meeting.graetzls << @graetzl
    @meeting.build_address
  end

  # def edit
  # end

  def create
    puts params
    @meeting = current_user.meetings_initialized.build(meeting_params)
    @graetzl = Graetzl.find(params[:graetzl_id])
    @meeting.graetzls << @graetzl
    #@meeting.address = Address.get_address_from_api(@meeting.address.street_name)
    #@meeting.address.description = meeting_params[:address_attributes][:description]
    @meeting.ends_at_date = @meeting.starts_at_date
    
    respond_to do |format|
      if @meeting.save
        format.html { redirect_to graetzl_meeting_path(@graetzl, @meeting), notice: 'Neues Treffen wurde erstellt.' }
      else
        format.html { render :new }
      end
    end
  end

  # def update
  #   respond_to do |format|
  #     if @meeting.update(meeting_params)
  #       format.html { redirect_to @meeting, notice: 'Meeting was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @meeting }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @meeting.errors, status: :unprocessable_entity }
  #     end
  #   end
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
        :starts_at_date, :starts_at_time,
        :ends_at_time,
        :cover_photo,
        :feature,
        category_ids: [],
        address_attributes: [:street_name, :description])
    end
end
