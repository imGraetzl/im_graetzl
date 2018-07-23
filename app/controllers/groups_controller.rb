class GroupsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    @group = Group.find(params[:id])
    if @group.readable_by?(current_user)
      @next_meeting = @group.meetings.where("DATE(starts_at_date) >= ?", Date.today).order(:starts_at_date, :starts_at_time).first
      @discussions = @group.discussions.where(discussion_filtering_params).includes(discussion_posts: :user).order("sticky DESC, last_post_at DESC")
      p params
      p !!params[:group_category]
      p params.has_key?(:group_category)
      if params.has_key?(:group_category) && params[:group_category]
        @group_category_title = @group.group_categories.find(params[:group_category]).title
      else
        @group_category_title = "Nicht kategorisiert"
      end
      @meetings = @group.meetings.order("starts_at_date ASC")
    end

    # Just for testing ... TODO
    @activity_sample = ActivitySample.new

  end

  def settings
    @group = Group.find(params[:id])
    render 'settings'
  end
  
  def categories
    @group = Group.find(params[:id])
    @group_categories = @group.group_categories
    @new_category = GroupCategory.new(group_id: params[:id])
    render 'categories'
  end
  
  def create_category
    @group = Group.find(params[:id])
    redirect_to @group and return unless @group.admins.include?(current_user)
    group_category = GroupCategory.new(group_category_params)
    if group_category.save
      redirect_to categories_group_url(@group)
    else
      redirect_to categories_group_url(@group), notice: 'Error creating category'
    end
  end

  def new
    @group = Group.new(
      room_offer_id: params[:room_offer_id],
      room_call_id: params[:room_call_id]
    )
  end

  def create
    @group = Group.new(group_params)
    @group.group_users.build(user_id: current_user.id, role: :admin)

    if @group.save
      redirect_to @group
    else
      render 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
    redirect_to @group and return unless @group.admins.include?(current_user)
  end

  def update
    @group = Group.find(params[:id])
    redirect_to @group and return unless @group.admins.include?(current_user)

    if @group.update(group_params)
      redirect_to @group
    else
      render 'edit'
    end
  end

  def request_join
    @group = Group.find(params[:id])
    if !@group.group_join_requests.exists?(user: current_user)
      join_request = @group.group_join_requests.create(
        user: current_user,
        request_message: params[:request_message]
      )
      GroupMailer.new.new_join_request(join_request)
    end

    redirect_to @group
  end

  def accept_request
    @group = Group.find(params[:id])
    redirect_to @group and return unless @group.admins.include?(current_user)

    @join_request = @group.group_join_requests.find(params[:join_request_id])
    @group.users << @join_request.user
    @join_request.destroy
    GroupMailer.new.join_request_accepted(@group, @join_request.user)
    redirect_to group_url(@group, anchor: "tab-members")
  end

  def reject_request
    @group = Group.find(params[:id])
    redirect_to @group and return unless @group.admins.include?(current_user)

    @join_request = @group.group_join_requests.find(params[:join_request_id])
    @join_request.update(rejected: true)
    redirect_to group_url(@group, anchor: "tab-members")
  end

  def remove_user
    @group = Group.find(params[:id])
    @group_user = @group.group_users.find_by(user_id: params[:user_id])
    redirect_to @group and return unless (@group.admins.include?(current_user) || current_user.id == @group_user.user_id)

    @group_user.destroy
    redirect_to group_url(@group, anchor: "tab-members")
  end

  def destroy
    @group = Group.find(params[:id])
    redirect_to @group and return unless @group.admins.include?(current_user)

    @group.destroy
    redirect_to root_path, notice: 'Gruppe gelöscht'
  end

  private

  def prepare_top_posts(group)
    top_posts = []
    sticky_discussion = group.discussions.sticky.last
    top_posts << sticky_discussion.posts.first if sticky_discussion
    # top_posts <<
    top_posts
  end
  
  def group_category_params
    params
      .require(:group_category)
      .permit(:title, :group_id)
  end
  
  def discussion_filtering_params
    if params[:group_category] == ''
      params[:group_category] = nil
    end
    params
      .permit(:group_category)
  end

  def group_params
    params
      .require(:group)
      .permit(
        :title,
        :description,
        :room_offer_id,
        :room_call_id,
        :private
    )
  end
end
