class MeetingsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  include GraetzlChild

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

  def edit
    @meeting = find_user_meeting
  end

  def update
    @meeting = find_user_meeting
    old_address_id = @meeting.address.try(:id)
    @meeting.attributes = update_meeting_params
    @meeting.graetzl = @meeting.address.graetzl if @meeting.address.try(:graetzl)
    changed_attributes = @meeting.changed_attributes
    if @meeting.address.present? && !@meeting.address.changed_attributes.blank?
      changed_attributes = changed_attributes.merge({ address: @meeting.address.changed_attributes })
    end
    if @meeting.basic!
      if @meeting.address.try(:id) != old_address_id
        changed_attributes = changed_attributes.merge({ address_attributes: old_address_id })
      end
      changed_attribute_keys = changed_attributes.keys.collect(&:to_sym)
      if changed_attribute_keys.any? { |a| [ :address, :address_attributes, :starts_at_time, :starts_at_date, :ends_at_time, :description ].include?(a) }
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
    @meeting = find_user_meeting
    @meeting.create_activity(:cancel, owner: current_user) if @meeting.cancelled!
    redirect_to @meeting.graetzl, notice: 'Dein Treffen wurde abgesagt.'
  end

  private

  def create_meeting_params
    if params[:feature].present?
      meeting_params.to_h.deep_merge(
        address_attributes: address_attr,
        going_tos_attributes: user_attr)
    else
      meeting_params.to_h.deep_merge(going_tos_attributes: user_attr)
    end
  end

  def update_meeting_params
    if params[:address].nil? && params[:feature].nil?
      meeting_params
    elsif params[:address].present? && params[:feature].blank?
      meeting_params
    else
      meeting_params.to_h.deep_merge(address_attributes: address_attr)
    end
  end

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

  def find_user_meeting
    current_user.meetings.initiated.find params[:id]
  end
end
