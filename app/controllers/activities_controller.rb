class ActivitiesController < ApplicationController

  def index
    head :ok and return if browser.bot? && !request.format.js?

    if params[:favorites].present? && current_user
      graetzl_ids = current_user.followed_graetzl_ids
    elsif params[:graetzl_id].present?
      graetzl_ids = [Graetzl.find(params[:graetzl_id]).id]
    elsif params[:district_id].present?
      graetzl_ids = District.find(params[:district_id]).graetzl_ids
    elsif params.dig(:filter, :graetzl_ids)&.compact_blank.present?
      graetzl_ids = Graetzl.where(id: params[:filter][:graetzl_ids]).pluck(:id)
    elsif params.dig(:filter, :district_ids)&.compact_blank.present?
      graetzl_ids = DistrictGraetzl.where(district_id: params[:filter][:district_ids]).distinct.pluck(:graetzl_id)
    end

    @activities = ActivityStream.new.fetch(current_region, current_user, graetzl_ids)
    @activities = @activities.page(params[:page]).per(12)

    if params[:page].blank?
      @activities_with_zuckerls = insert_zuckerls(@activities, graetzl_ids)
    end
  end

  private

  def insert_zuckerls(activities, graetzl_ids)
    zuckerls = Zuckerl.live.in(current_region)
    zuckerls = zuckerls.in_area(graetzl_ids) if graetzl_ids.present?
    zuckerls = zuckerls.include_for_box.random(3)

    result = activities.to_a
    result.insert(3, zuckerls[0]) if zuckerls[0]
    result.insert(7, zuckerls[1]) if zuckerls[1]
    result.insert(12, zuckerls[2]) if zuckerls[2]
    result.compact
  end

end
