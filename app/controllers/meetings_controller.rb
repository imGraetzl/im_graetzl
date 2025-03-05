class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @meetings = collection_scope.in(current_region).include_for_box
    @meetings = filter_collection(@meetings)
    @meetings = @meetings.page(params[:page]).per(params[:per_page] || 30)
    @meetings = @meetings.upcoming if params[:upcoming]
    @meetings = @meetings.past if params[:past]
    @meetings = @meetings.where.not(id: params[:exclude].to_i) if params[:exclude]
  end

  def show
    @meeting = Meeting.find(params[:id])
    redirect_to_region?(@meeting)
    @graetzl = @meeting.graetzl
    @comments = @meeting.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @meeting = current_user.initiated_meetings.build(location_id: params[:location_id])
    @meeting.graetzl = params[:graetzl_id].present? ? Graetzl.find(params[:graetzl_id]) : user_home_graetzl
  end

  def create
    @meeting = Meeting.new(meeting_params)
    @meeting.clear_address if @meeting.online_meeting?
    @meeting.assign_attributes(ends_at_date: nil) if params[:date_option] != 'range' || @meeting.starts_at_date == @meeting.ends_at_date
    @meeting.meeting_additional_dates.delete_all if params[:date_option] != 'multiple'
    @meeting.user = current_user.admin_or_beta? ? User.confirmed.find(params[:user_id]) : current_user
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
    starts_at_time_before = @meeting.starts_at_time

    @meeting.user = current_user.admin_or_beta? ? User.confirmed.find(params[:user_id]) : current_user
    @meeting.assign_attributes(meeting_params)
    @meeting.state = :active
    @meeting.clear_address if @meeting.online_meeting?
    @meeting.assign_attributes(ends_at_date: nil) if params[:date_option] != 'range' || @meeting.starts_at_date == @meeting.ends_at_date
    @meeting.meeting_additional_dates.delete_all if params[:date_option] != 'multiple'

    if @meeting.save

      # Create new Activity and Notifications if StartDate has changed from past into future
      if starts_at_date_before < Date.today && starts_at_date_before != @meeting.starts_at_date
        
        ActionProcessor.track(@meeting, :create) if @meeting.refresh_activity
      
      # Update Notifications and GoingTo Dates if Start Date is in future and changes
      elsif starts_at_date_before >= Date.today && (starts_at_date_before != @meeting.starts_at_date || starts_at_time_before != @meeting.starts_at_time)
        
        ActionProcessor.track(@meeting, :update)
        @meeting.going_tos.where(going_to_date: starts_at_date_before, going_to_time: starts_at_time_before).update_all(
          going_to_date: @meeting.starts_at_date,
          going_to_time: @meeting.starts_at_time
        )

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

    User.registered.where(id: params[:user_ids]).find_each do |user|
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
      meetings = meetings.where(graetzl_id: favorite_ids).or(meetings.entire_region)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      meetings = meetings.where(graetzl_id: graetzl_ids).or(meetings.entire_region)
    end

    if params[:special_category_id].present? && params[:special_category_id] == 'balkon-solar'
      meetings = meetings.joins(:event_categories).where(event_categories: {slug: params[:special_category_id]})
    elsif params[:category_id].present?
      meetings = meetings.joins(:event_categories).where(event_categories: {id: params[:category_id]})
    end

    # DATE FILTER
    date_from = params[:date_from_submit].presence
    date_to = params[:date_to_submit].presence

    # Falls mindestens ein Datum gesetzt ist, Filter anwenden
    if date_from.present? || date_to.present?
      safe_date_from = date_from.presence || Date.today.to_s
      safe_date_to = date_to.presence || '9999-12-31'
      
      meetings = meetings
        .left_joins(:meeting_additional_dates)
        .where(
          "(meetings.starts_at_date BETWEEN ? AND ?) 
          OR (meeting_additional_dates.id IS NOT NULL AND meeting_additional_dates.starts_at_date BETWEEN ? AND ?)",
          safe_date_from, safe_date_to, safe_date_from, safe_date_to
        )

      # Sicherstellen, dass das Meeting-Datum priorisiert wird, falls es in den Filter passt
      meetings = meetings.select(
        "meetings.*, 
        CASE 
          WHEN meetings.starts_at_date BETWEEN '#{safe_date_from}' AND '#{safe_date_to}' THEN 1 
          WHEN meeting_additional_dates.id IS NOT NULL AND meeting_additional_dates.starts_at_date BETWEEN '#{safe_date_from}' AND '#{safe_date_to}' THEN 2
          ELSE 3
        END AS date_source_priority, 
        CASE 
          WHEN meetings.starts_at_date BETWEEN '#{safe_date_from}' AND '#{safe_date_to}' THEN meetings.starts_at_date
          WHEN meeting_additional_dates.id IS NOT NULL AND meeting_additional_dates.starts_at_date BETWEEN '#{safe_date_from}' AND '#{safe_date_to}' THEN meeting_additional_dates.starts_at_date
          ELSE NULL
        END AS display_date"
      )

      # Sortierung nach `display_date`, dann nach Priorität, dann nach Erstellungsdatum
      meetings = meetings.order(Arel.sql("display_date ASC, date_source_priority ASC, meetings.created_at DESC")).distinct
    else
      meetings = meetings.by_currentness
    end

    meetings
  end

  def meeting_params
    list_params_allowed = [
      :graetzl_id, :location_id, :poll_id, :name, :description, :max_going_tos,
      :starts_at_date, :ends_at_date, :starts_at_time, :ends_at_time,
      :cover_photo, :remove_cover_photo,
      :address_street, :address_coords, :address_city, :address_zip, :address_description, :using_address,
      :online_meeting, :online_description, :online_url,
      images_attributes: [:id, :file, :_destroy],
      event_category_ids: [],
      meeting_additional_dates_attributes: [
        :id, :starts_at_date, :starts_at_time, :ends_at_time, :_destroy
      ],
    ]
    list_params_allowed << :entire_region if current_user.admin?
    list_params_allowed << :user_id if current_user.admin_or_beta?
    params.require(:meeting).permit(list_params_allowed)
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
