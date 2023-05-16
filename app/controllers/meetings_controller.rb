class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @meetings = collection_scope.in(current_region).include_for_box
    @meetings = filter_collection(@meetings)
    @meetings = @meetings.visible_to(current_user)
    @meetings = @meetings.by_currentness.page(params[:page]).per(params[:per_page] || 30)
    @meetings = @meetings.upcoming if params[:upcoming]
    @meetings = @meetings.past if params[:past]
    @meetings = @meetings.where.not(id: params[:exclude].to_i) if params[:exclude]
  end

  def show
    @meeting = Meeting.in(current_region).find(params[:id])
    @graetzl = @meeting.graetzl
    @comments = @meeting.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @meeting = current_user.initiated_meetings.build(group_id: params[:group_id], location_id: params[:location_id])
    @meeting.graetzl = params[:graetzl_id].present? ? Graetzl.find(params[:graetzl_id]) : user_home_graetzl
  end

  def create
    @meeting = Meeting.new(meeting_params)
    @meeting.clear_address if @meeting.online_meeting?
    @meeting.assign_attributes(ends_at_date: nil) if params[:date_option] != 'range' || @meeting.starts_at_date == @meeting.ends_at_date
    @meeting.meeting_additional_dates.delete_all if params[:date_option] != 'multiple'
    @meeting.user = current_user.admin? ? User.find(params[:user_id]) : current_user
    @meeting.region_id = current_region.id
    @meeting.going_tos.build(user_id: @meeting.user.id, role: :initiator)
    @meeting.last_activated_at = Time.now

    if !current_user.admin? && meeting = Meeting.upcoming.where(user_id: current_user.id).where(name: @meeting.name).last
      flash.now[:notice] = "Du hast bereits ein zukünftiges Treffen mit dem Titel: '#{view_context.link_to meeting, [meeting.graetzl, meeting]}' erstellt. Du kannst dieses #{view_context.link_to 'hier bearbeiten', edit_meeting_path(meeting)} um es zu aktualisieren bzw. um weitere Termine hinzuzufügen."
      render 'new'
    else
      if @meeting.save
        ActionProcessor.track(@meeting, :create)
        redirect_to [@meeting.graetzl, @meeting]
      else
        render 'new'
      end
    end

  end

  def edit
    @meeting = find_user_meeting
  end

  def update
    @meeting = find_user_meeting
    starts_at_date_before = @meeting.starts_at_date

    @meeting.assign_attributes(meeting_params)
    @meeting.state = :active
    @meeting.clear_address if @meeting.online_meeting?
    @meeting.assign_attributes(ends_at_date: nil) if params[:date_option] != 'range' || @meeting.starts_at_date == @meeting.ends_at_date
    @meeting.meeting_additional_dates.delete_all if params[:date_option] != 'multiple'

    if @meeting.save

      # Create new Activity and Notifications if StartDate has changed from past into future
      if starts_at_date_before < Date.today && starts_at_date_before != @meeting.starts_at_date
        ActionProcessor.track(@meeting, :create) if @meeting.refresh_activity
      elsif starts_at_date_before != @meeting.starts_at_date
        ActionProcessor.track(@meeting, :update)
      end

      redirect_to [@meeting.graetzl, @meeting]
    else
      render :edit
    end
  end

  def attend
    @meeting = Meeting.find(params[:id])
    going_to = @meeting.going_tos.new(user_id: current_user.id)

    if params[:meeting_additional_date_id] == 'original_date'
      going_to.going_to_date = @meeting.starts_at_date
      going_to.going_to_time = @meeting.starts_at_time
    elsif params[:meeting_additional_date_id].present?
      additional_date = MeetingAdditionalDate.find(params[:meeting_additional_date_id])
      going_to.going_to_date = additional_date.starts_at_date
      going_to.going_to_time = additional_date.starts_at_time
      going_to.meeting_additional_date_id = additional_date.id
    end

    going_to.save
    ActionProcessor.track(@meeting, :attended, going_to)

    redirect_to [@meeting.graetzl, @meeting]
  end

  def unattend
    @meeting = Meeting.find(params[:id])
    @meeting.going_tos.where(user_id: current_user.id).destroy_all
    redirect_to [@meeting.graetzl, @meeting]
  end

  def destroy
    @meeting = find_user_meeting
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
        @meeting, current_user, user, params[:subject], params[:body]
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
    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      meetings = meetings.where(graetzl_id: favorite_ids)
      #meetings = meetings.where(graetzl_id: favorite_ids).or(meetings.online_meeting)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      meetings = meetings.where(graetzl_id: graetzl_ids)
    end

    if params[:category_id].present?
      meetings = meetings.joins(:event_categories).where(event_categories: {id: params[:category_id]})
    end

    meetings
  end

  def meeting_params
    params.require(:meeting).permit(
      :graetzl_id, :group_id, :location_id, :name, :description,
      :starts_at_date, :ends_at_date, :starts_at_time, :ends_at_time,
      :cover_photo, :remove_cover_photo,
      :address_street, :address_coords, :address_city, :address_zip, :address_description, :using_address,
      :online_meeting, :online_description, :online_url,
      images_attributes: [:id, :file, :_destroy],
      event_category_ids: [],
      meeting_additional_dates_attributes: [
        :id, :starts_at_date, :starts_at_time, :ends_at_time, :_destroy
      ],
    )
  end

  def going_to_params
    params.permit(
      :meeting_id, :meeting_additional_date_id
    )
  end

  def find_user_meeting
    current_user.initiated_meetings.find(params[:id])
  end
end
