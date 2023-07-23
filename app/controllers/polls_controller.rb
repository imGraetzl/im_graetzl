class PollsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    polls = collection_scope.in(current_region).include_for_box
    polls = filter_collection(polls)

    @polls = []

    energieteiler_type = params.dig(:filter, :energieteiler_type)

    if energieteiler_type.present?

      #meetings_upcoming = Meeting.in(current_region).upcoming.include_for_box.joins(:poll).page(params[:page]).per(params[:per_page] || 30)
      
      # MEETING COLLECTION
      if ['meeting', 'all'].include?(energieteiler_type)
        meeting_category = EventCategory.where("title ILIKE :q", q: "%Energieteiler%").last
        meetings_upcoming = Meeting.in(current_region).upcoming.include_for_box.joins(:event_categories).where(event_categories: {id: meeting_category&.id}).page(params[:page]).per(params[:per_page] || 30)
        meetings_past = Meeting.in(current_region).past.include_for_box.joins(:event_categories).where(event_categories: {id: meeting_category&.id}).page(params[:page]).per(params[:per_page] || 30)
        meetings_upcoming = filter_meetings(meetings_upcoming)
        meetings_past = filter_meetings(meetings_past)
      else
        meetings_upcoming = Meeting.none
        meetings_past = Meeting.none  
      end

      # LOCATION COLLECTION
      if ['location', 'all'].include?(energieteiler_type)
        location_category = LocationCategory.where("name ILIKE :q", q: "%Energieteiler%").last
        locations = Location.in(current_region).where(location_category_id: location_category&.id).include_for_box.page(params[:page]).per(params[:per_page] || 30)
        locations = filter_locations(locations)
      else
        locations = Location.none
      end

      # POLLS COLLECTION
      if ['poll', 'all'].include?(energieteiler_type)
        polls = polls.scope_public.by_zip.page(params[:page]).per(params[:per_page] || 30)
      else
        polls = Poll.none
      end
      
      # COMBINE ALL COLLECTIONS
      polls_and_locations = (polls + locations).sort_by(&:last_activity_at).reverse
      @polls += (meetings_upcoming + polls_and_locations + meetings_past)

      @next_page = 
      (polls.present? && polls.next_page.present?) || 
      (locations.present? && locations.next_page.present?) || 
      (meetings_upcoming.present? && meetings_upcoming.next_page.present?) ||
      (meetings_past.present? && meetings_past.next_page.present?)
    
    else

      polls = polls.scope_public.by_currentness.page(params[:page]).per(params[:per_page] || 30)
      @polls += polls
      @next_page = polls.next_page.present?  
      
    end

  end

  def show
    @poll = Poll.in(current_region).find(params[:id])
    @comments = @poll.comments.includes(:user, :images).order(created_at: :desc)
  end

  def unattend
    @poll = Poll.in(current_region).find(params[:id])
    @poll.poll_users.where(user_id: current_user.id).destroy_all
    redirect_to @poll
  end

  private

  def collection_scope
    Poll.all
  end

  def filter_collection(collection)

    if params[:poll_type].present?
      collection = collection.where(poll_type: params[:poll_type])
    end

    graetzl_ids = params.dig(:filter, :graetzl_ids)
    if params[:favorites].present? && current_user
      favorite_ids = current_user.followed_graetzl_ids
      collection = collection.joins(:poll_graetzls).where(poll_graetzls: {graetzl_id: favorite_ids}).distinct
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      collection = collection.joins(:poll_graetzls).where(poll_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    collection
  end

  def filter_locations(locations)
    graetzl_ids = params.dig(:filter, :graetzl_ids)

    if params[:favorites].present? && current_user
      locations = locations.where(graetzl_id: current_user.followed_graetzl_ids)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      locations = locations.where(graetzl_id: graetzl_ids)
    end

    locations
  end

  def filter_meetings(meetings)
    graetzl_ids = params.dig(:filter, :graetzl_ids)

    if params[:favorites].present? && current_user
      meetings = meetings.where(graetzl_id: current_user.followed_graetzl_ids)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      meetings = meetings.where(graetzl_id: graetzl_ids)
    end

    meetings
  end

end
