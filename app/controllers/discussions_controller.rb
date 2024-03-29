class DiscussionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :check_group

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @discussions = @group.discussions.order("sticky DESC, last_post_at DESC")
    @discussions = @discussions.includes(:user, :discussion_category, first_post: [:images], discussion_posts: [:user])

    discussion_category_id = params.dig(:filter, :discussion_category)
    if discussion_category_id.present?
      @discussions = @discussions.where(discussion_category_id: discussion_category_id)
      @category = @group.discussion_categories.find(discussion_category_id)
    end

    @discussions = @discussions.page(params[:page]).per(params[:per_page] || 15)

    render 'groups/discussions/index'
  end

  def show
    @discussion = @group.discussions.find(params[:id])
    @posts = @discussion.discussion_posts.includes(:group, :images, :user,  comments: [:images, :user])
    render 'groups/discussions/show'
  end

  def new
    render 'groups/discussions/new'
  end

  def create
    @discussion = @group.discussions.build(discussion_params)
    @discussion.user = current_user
    @discussion.discussion_posts.build(discussion_post_params.merge(initial_post: true, user: current_user))
    if @discussion.save
      @discussion.discussion_followings.create(user: current_user)
      notify = @group.default_joined? ? @group.admins.include?(current_user) && params[:trigger_notification].present? : true
      ActionProcessor.track(@discussion, notify ? :create : :create_without_notify)
      redirect_to [@group, @discussion, anchor: "topic"]
    else
      redirect_to [@group, @discussion]
    end
  end

  def edit
    @discussion = @group.discussions.find(params[:id])
    render 'groups/discussions/edit'
  end

  def update
    @discussion = @group.discussions.find(params[:id])
    redirect_to [@group, @discussion] and return if @discussion.user != current_user && !current_user.admin?
    @discussion.update(discussion_params)
    redirect_to [@group, @discussion]
  end

  def toggle_following
    @discussion = @group.discussions.find(params[:id])
    following = @discussion.discussion_followings.find_by(user: current_user)
    if following
      following.destroy
    else
      @discussion.discussion_followings.create(user: current_user)
    end

    head :ok
  end

  def destroy
    @discussion = @group.discussions.find(params[:id])
    if @discussion && @discussion.delete_permission?(current_user)
      @discussion.destroy
      redirect_to @group
    else
      head :ok
    end
  end

  private

  def check_group
    @group = Group.find(params[:group_id])
    if @group.nil?
      flash[:error] = "Gruppe nicht gefunden."
      redirect_to root_url
    elsif !@group.readable_by?(current_user) && current_user
      flash[:error] = "Nur für Gruppenmitglieder - Falls du Gruppenmitglied bist, logge dich bitte vorher ein."
      redirect_to @group
    elsif !@group.readable_by?(current_user)
      flash[:error] = "Nur für eingeloggte Gruppenmitglieder - Falls du Gruppenmitglied bist, logge dich bitte vorher ein."
      redirect_to new_user_session_url(redirect: request.original_url)
    end
  end

  def discussion_params
    params.require(:discussion).permit(:title, :sticky, :closed, :discussion_category_id)
  end

  def discussion_post_params
    params.require(:discussion).require(:initial_post).permit(
      :content,
      images_attributes: [:id, :file, :_destroy],
    )
  end
end
