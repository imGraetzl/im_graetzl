class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  include GraetzlChild
  before_action :set_meeting, except: [:index, :new, :create]
  before_action :check_permission!, only: [:edit, :update, :destroy]

  def index
    @meetings = @graetzl.meetings.
      by_currentness.
      page(params[:page]).per(15)
  end

  def show
    verify_graetzl_child(@meeting) unless request.xhr?
    @comments = @meeting.comments.
      order(created_at: :desc).
      page(params[:page]).per(10)
  end

  def new
    graetzl = current_user.graetzl
    @meeting = graetzl.build_meeting
  end

  def create
    @parent ||= current_user.graetzl
    @meeting = Meeting.new create_meeting_params

    # set different graetzl if address in different graetzl:
    @meeting.graetzl = @meeting.address.try(:graetzl) || @meeting.graetzl
    if @meeting.save
      @meeting.create_activity :create, owner: current_user
      redirect_to [@meeting.graetzl, @meeting]
    else
      render :new
    end
  end

  # def create
  #   @parent = parent_context
  #   @meeting = @parent.meetings.new meeting_params
  #   # @meeting = Meeting.new(meeting_params)
  #
  #   # set different graetzl if address in different graetzl:
  #   @meeting.graetzl = @meeting.address.try(:graetzl) || @meeting.graetzl
  #   # @meeting.graetzl = @meeting.address.graetzl if @meeting.address
  #   @meeting.going_tos.build(user: current_user, role: GoingTo.roles[:initiator])
  #
  #   if @meeting.save
  #     @meeting.create_activity :create, owner: current_user
  #     redirect_to [@meeting.graetzl, @meeting]
  #   else
  #     render :new
  #   end
  # end

  # def update
  #   old_address_id = @meeting.address.try(:id)
  #   @meeting.attributes = meeting_params
  #   @meeting.graetzl = @meeting.address.graetzl if @meeting.address.graetzl
  #   changed_attributes = @meeting.changed_attributes
  #   if @meeting.address.present? && !@meeting.address.changed_attributes.blank?
  #     changed_attributes = changed_attributes.merge({ address: @meeting.address.changed_attributes })
  #   end
  #   if @meeting.save
  #     if @meeting.address.try(:id) != old_address_id
  #       changed_attributes = changed_attributes.merge({ address_attributes: old_address_id })
  #     end
  #     changed_attribute_keys = changed_attributes.keys.collect(&:to_sym)
  #     if changed_attribute_keys.any? { |a| [ :address, :address_attributes, :starts_at_time, :starts_at_date, :ends_at_time, :description ].include?(a) }
  #       @meeting.create_activity :update,
  #         owner: current_user,
  #         parameters: { changed_attributes: changed_attribute_keys }
  #     end
  #     redirect_to [@meeting.graetzl, @meeting]
  #   else
  #     render :edit
  #   end
  # end
  #
  # def destroy
  #   @meeting.cancelled!
  #   @meeting.create_activity :cancel, owner: current_user
  #   redirect_to @meeting.graetzl, notice: 'Dein Treffen wurde abgesagt.'
  # end

  private

  def create_meeting_params
    if params[:feature].present?
      meeting_params.deep_merge(
        address_attributes: address_attr,
        going_tos_attributes: user_attr)
    else
      meeting_params.deep_merge(going_tos_attributes: user_attr)
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  # def meeting_params
  #   if params[:address].nil? && params[:feature].nil?
  #     meeting_params_basic
  #   elsif params[:address].present? && params[:feature].blank?
  #     meeting_params_basic
  #   else
  #     meeting_params_basic.deep_merge(address_attributes: address_attr)
  #   end
  # end

  def meeting_params
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

  def user_attr
    { 0 => { user_id: current_user.id, role: GoingTo.roles[:initiator] } }
  end

  def set_meeting
    @meeting = Meeting.find(params[:id])
  end

  def parent_context
    base = (params[:meeting] if params[:meeting].present?) || params
    context = Location.find(base[:location_id]) if base[:location_id].present?
    context ||= Graetzl.find(base[:graetzl_id]) if base[:graetzl_id].present?
    context || current_user.graetzl
  end

  def check_permission!
    if !@meeting.going_tos.initiator.find_by_user_id(current_user)
      flash[:error] = 'Nur Initiatoren können Treffen bearbeiten.'
      redirect_to [@meeting.graetzl, @meeting]
    end
  end
end
