class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  include GraetzlChild
  before_action :set_meeting, except: [:index, :new, :create]
  before_action :check_permission!, only: [:edit, :update, :destroy]

  def index
    @upcoming_meetings = @graetzl.meetings.upcoming
    @past_meetings = @graetzl.meetings.past
  end

  def show
    verify_graetzl_child(@meeting)
    @comments = @meeting.comments
  end

  def new
    @parent = parent_context
    @meeting = @parent.meetings.build()
    if location = @meeting.location
      @meeting.graetzl = location.graetzl
      @meeting.build_address(location.address.attributes.merge(description: location.name))
    else
      @meeting.build_address
    end
  end

  def create
    @meeting = Meeting.new(meeting_params)
    @meeting.graetzl = @meeting.address.graetzl if @meeting.address.graetzl
    @meeting.going_tos.build(user: current_user, role: GoingTo.roles[:initiator])
    
    if @meeting.save
      @meeting.create_activity :create, owner: current_user
      redirect_to [@meeting.graetzl, @meeting]
    else
      render :new
    end
  end

  def update
    old_address_id = @meeting.address.try(:id)
    @meeting.attributes = meeting_params
    @meeting.graetzl = @meeting.address.graetzl if @meeting.address.graetzl
    changed_attributes = @meeting.changed_attributes
    if @meeting.address.present? && !@meeting.address.changed_attributes.blank?
      changed_attributes = changed_attributes.merge({ address: @meeting.address.changed_attributes })
    end
    if @meeting.save
      if @meeting.address.try(:id) != old_address_id
        changed_attributes = changed_attributes.merge({ address_attritbutes: old_address_id })
      end
      changed_attribute_keys = changed_attributes.keys.collect(&:to_sym)
      if changed_attribute_keys.any? { |a| [ :address, :address_attritbutes, :starts_at_time, :starts_at_date, :ends_at_time, :ends_at_date, :description ].include?(a) }
        @meeting.create_activity :update,
          owner: current_user,
          parameters: { changed_attributes: changed_attribute_keys }
      end
      redirect_to [@meeting.graetzl, @meeting]
    else
      render :edit
    end
  end

  def destroy
    graetzl = @meeting.destroy.graetzl
    redirect_to graetzl, notice: 'Dein Treffen wurde abgesagt.'
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
        permit(:graetzl_id,
          :name,
          :description,
          :starts_at_date, :starts_at_time,
          :ends_at_time,
          :cover_photo,
          :remove_cover_photo,
          :location_id,
          category_ids: [],
          address_attributes: [
            :id,
            :description,
            :street_name,
            :street_number,
            :zip,
            :city,
            :coordinates])
    end

    def address_attr
      Address.attributes_from_feature(params[:feature]) || Address.attributes_to_reset_location
    end

    def set_meeting
      @meeting = Meeting.eager_load(:going_tos).find(params[:id])
    end

    def parent_context
      context = Location.find(params[:location_id]) if params[:location_id].present?
      context ||= Graetzl.find(params[:graetzl_id]) if params[:graetzl_id].present?
      context || current_user.graetzl
    end

    def check_permission!
      unless @meeting.going_tos.initiator.find_by_user_id(current_user)
        flash[:error] = 'Nur Initiatoren können Treffen bearbeiten.'
        redirect_to [@meeting.graetzl, @meeting]
      end
    end
end
