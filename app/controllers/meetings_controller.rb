class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @meetings = collection_scope.include_for_box
    @meetings = filter_collection(@meetings)
    @meetings = @meetings.visible_to(current_user)
    @meetings = @meetings.by_currentness.page(params[:page]).per(params[:per_page] || 30)
  end

  def show
    @graetzl = Graetzl.find(params[:graetzl_id])
    @meeting = @graetzl.meetings.find(params[:id])
    @comments = @meeting.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @meeting = initialize_meeting
    @meeting.build_platform_meeting_join_request
  end

  def create
    @meeting = Meeting.new(meeting_params)
    @meeting.address = nil if @meeting.online_meeting?
    @meeting.user = current_user.admin? ? User.find(params[:user_id]) : current_user
    @meeting.going_tos.build(user_id: @meeting.user.id, role: :initiator)

    if @meeting.save
      @meeting.create_activity :create, owner: @meeting.user, cross_platform: @meeting.online_meeting?
      redirect_to [@meeting.graetzl, @meeting]
    else
      render 'new'
    end
  end

  def edit
    @meeting = find_user_meeting
    if @meeting.platform_meeting_join_request.nil?
      @meeting.build_platform_meeting_join_request
    end
  end

  def update
    @meeting = find_user_meeting
    @meeting.assign_attributes(meeting_params)
    @meeting.address = nil if @meeting.online_meeting?

    @meeting.state = :active

    if @meeting.save
      redirect_to [@meeting.graetzl, @meeting]
    else
      render :edit
    end
  end

  def attend
    @meeting = Meeting.find(params[:id])
    if params[:meeting_additional_date_id].present?
      if params[:meeting_additional_date_id] == 'original_date'
        @meeting.going_tos.new(
          user_id: current_user.id,
          going_to_date: @meeting.starts_at_date,
          going_to_time: @meeting.starts_at_time,
        )
      else
        @meeting_additional_date = MeetingAdditionalDate.find(params[:meeting_additional_date_id])
        @meeting.going_tos.new(
          user_id: current_user.id,
          going_to_date: @meeting_additional_date.starts_at_date,
          going_to_time: @meeting_additional_date.starts_at_time,
          meeting_additional_date_id: @meeting_additional_date.id,
        )
      end
    else
      @meeting.going_tos.new(
        user_id: current_user.id,
      )
    end
    @meeting.save

    @meeting.create_activity :go_to, owner: current_user, cross_platform: @meeting.online_meeting?

    #flash[:notice] = "Du wurdest als InteressentIn hinzugefügt."
    redirect_to [@meeting.graetzl, @meeting]
  end

  def unattend
    @meeting = Meeting.find(params[:id])
    @meeting.going_tos.where(user_id: current_user.id).destroy_all
    redirect_to [@meeting.graetzl, @meeting]
  end

  def destroy
    @meeting = find_user_meeting
    # Meeting auf Cancelled setzen:
    # Erklärung: call method if method returns true (cancelled wird ausgeführt, dann activity)
    #@meeting.create_activity(:cancel, owner: current_user) if @meeting.cancelled!
    #redirect_to @meeting.graetzl, notice: 'Dein Treffen wurde abgesagt.'

    @meeting.destroy
    redirect_to root_path, notice: 'Dein Treffen wurde gelöscht.'

  end

  def compose_mail
    @meeting = find_user_meeting
    redirect_to [@meeting.graetzl, @meeting] and return unless @meeting.user == current_user
  end

  def send_mail
    @meeting = find_user_meeting
    redirect_to [@meeting.graetzl, @meeting] and return unless @meeting.user == current_user

    User.where(id: params[:user_ids]).find_each do |user|
      MeetingMailer.message_to_user(
        @meeting, current_user, user, params[:subject], params[:body], params[:from_email]
      ).deliver_later
    end
    redirect_to [@meeting.graetzl, @meeting], notice: 'Deine E-Mail wurde versendet ..'
  end

  private

  def collection_scope
    if params[:location_id].present?
      Meeting.where(location_id: params[:location_id])
    elsif params[:district_id].present?
      district = District.find(params[:district_id])
      Meeting.where(graetzl_id: district.graetzl_ids)
    elsif params[:initiated_user_id].present?
      Meeting.where(user_id: params[:initiated_user_id])
    elsif params[:group_id].present?
      Meeting.where(group_id: params[:group_id])
    elsif params[:attended_user_id].present?
      user = User.find(params[:attended_user_id])
      user.attended_meetings
    elsif params[:platform_meeting].present?
      Meeting.where(platform_meeting: params[:platform_meeting])
    else
      Meeting.all
    end
  end

  def filter_collection(meetings)
    meeting_type = params.dig(:filter, :meeting_type)
    if meeting_type.present?
      if meeting_type == 'online'
        meetings = meetings.online_meeting
      elsif meeting_type == 'offline'
        meetings = meetings.offline_meeting
      end
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)
    if graetzl_ids.present? && graetzl_ids.any?(&:present?)
      meetings = meetings.where(graetzl_id: graetzl_ids).or(meetings.online_meeting)
    end

    if params[:special_category_id].present? && params[:special_category_id] == 'special-events'
      meetings = meetings.platform_meeting
    end

    if params[:category_id].present?
      meetings = meetings.joins(:event_categories).where(event_categories: {id: params[:category_id]})
    end

    if params[:meeting_category_id].present?
      meetings = meetings.where(meeting_category_id: params[:meeting_category_id])
    end

    meetings
  end

  def meeting_params
    params.require(:meeting).permit(
      :graetzl_id,
      :group_id,
      :name,
      :description,
      :meeting_category_id,
      :starts_at_date,
      :starts_at_time,
      :ends_at_time,
      :cover_photo,
      :remove_cover_photo,
      :location_id,
      :full_address,
      :address_description,
      :platform_meeting,
      :online_meeting,
      :online_description,
      :online_url,
      :amount,
      event_category_ids: [],
      meeting_additional_dates_attributes: [
        :id, :starts_at_date, :starts_at_time, :ends_at_time, :_destroy
      ],
      platform_meeting_join_request_attributes: [
        :id, :status, :request_message, :_destroy
      ],
    )
  end

  def going_to_params
    params.permit(
      :meeting_id, :meeting_additional_date_id
    )
  end

  def initialize_meeting
    if params[:group_id].present?
      Meeting.new(group: Group.find(params[:group_id]))
    elsif params[:graetzl_id].present?
      Meeting.new(graetzl: Graetzl.find(params[:graetzl_id]))
    else
      Meeting.new(graetzl: current_user.graetzl)
    end
  end

  def find_user_meeting
    current_user.initiated_meetings.find(params[:id])
  end
end
