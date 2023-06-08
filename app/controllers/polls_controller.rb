class PollsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    polls = collection_scope.in(current_region).include_for_box
    polls = filter_collection(polls)

    @polls = []

    if params[:meetings].present?

      meetings_upcoming = Meeting.in(current_region).upcoming.include_for_box.joins(:poll).page(params[:page]).per(params[:per_page] || 30)
      meetings_past = Meeting.in(current_region).past.include_for_box.joins(:poll).page(params[:page]).per(params[:per_page] || 30)
      
      polls = polls.scope_public.by_zip.page(params[:page]).per(params[:per_page] || 30)
      @polls += (meetings_upcoming + polls + meetings_past)
      @next_page = polls.next_page.present? || meetings_upcoming.next_page.present? || meetings_past.next_page.present?
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

end
