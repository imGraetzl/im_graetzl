class PollsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @polls = collection_scope.in(current_region).include_for_box
    @polls = filter_collection(@polls)
    @polls = @polls.by_currentness.page(params[:page]).per(params[:per_page] || 30)
  end

  def show
    @poll = Poll.in(current_region).find(params[:id])
    @comments = @poll.comments.includes(:user, :images).order(created_at: :desc)
  end

  private

  def collection_scope
    Poll.all
  end

  def filter_collection(collection)
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
