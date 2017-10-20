class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  include GraetzlChild

  def new
    graetzl = current_user.graetzl
    @meeting = graetzl.build_meeting
  end

  def create
    @parent ||= current_user.graetzl
    @meeting = Meeting.new(meeting_params)
    @meeting.graetzl = @meeting.address.try(:graetzl) || @meeting.graetzl
    @meeting.going_tos.new(user_id: current_user.id, role: :initiator)

    if @meeting.save
      @meeting.create_activity :create, owner: current_user
      redirect_to [@meeting.graetzl, @meeting]
    else
      render :new
    end
  end

  def edit
    @meeting = find_user_meeting
  end

  def update
    @meeting = find_user_meeting

    @meeting.assign_attributes(meeting_params)
    @meeting.graetzl = @meeting.address.graetzl if @meeting.address.try(:graetzl)
    @meeting.state = :basic

    changed_attributes = @meeting.changed_attributes.keys.map(&:to_sym)
    changed_attributes.push(:address) if @meeting.address.changed?

    if @meeting.save
      if (changed_attributes & [:address, :address_attributes, :starts_at_time, :starts_at_date, :ends_at_time, :description]).present?
        @meeting.create_activity :update, owner: current_user, parameters: { changed_attributes: changed_attributes }
      end
      redirect_to [@meeting.graetzl, @meeting]
    else
      render :edit
    end
  end

  def destroy
    @meeting = find_user_meeting
    @meeting.create_activity(:cancel, owner: current_user) if @meeting.cancelled!
    redirect_to @meeting.graetzl, notice: 'Dein Treffen wurde abgesagt.'
  end

  private

  def meeting_params
    result = params.require(:meeting).permit(:graetzl_id, :name, :description, :starts_at_date, :starts_at_time,
      :ends_at_time, :cover_photo, :remove_cover_photo, :location_id, category_ids: [],
      address_attributes: [:id, :description, :street_name, :street_number, :zip, :city, :coordinates]
    )
    
    feature_address = Address.from_feature(params[:feature]) if params[:feature]
    result[:address_attributes].merge!(feature_address.attributes.symbolize_keys.compact) if feature_address
    result
  end

  def find_user_meeting
    current_user.meetings.initiated.find params[:id]
  end
end
