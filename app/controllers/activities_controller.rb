class ActivitiesController < ApplicationController

  def index
    head :ok and return if browser.bot? && !request.format.js?

    if params[:graetzl_id].present?
      graetzl_ids = [Graetzl.find(params[:graetzl_id]).id]
    elsif params[:district_id].present?
      graetzl_ids = District.find(params[:district_id]).graetzl_ids
    end

    @activities = ActivityStream.new.fetch(current_region, current_user, graetzl_ids)
    @activities = @activities.page(params[:page]).per(12)

    if params[:page].blank?
      @activities_with_zuckerls = insert_zuckerls(@activities, graetzl_ids)
    end
  end

  def insert_zuckerls(graetzl_ids)
    zuckerls_sample_size = activity_items.size * 0.2
    zuckerls = Zuckerl.for_area(@area).limit(zuckerls_sample_size).order(Arel.sql("RANDOM()")).to_a
    zuckerl_items = Array.new(activity_items.size){|i| zuckerls[i] || nil}.shuffle
    activity_items.zip(zuckerl_items).flatten.compact
  end

  private

  def insert_zuckerls(activities, graetzl_ids)
    zuckerls = Zuckerl.in(current_region)
    zuckerls = zuckerls.in_area(graetzl_ids) if graetzl_ids.present?
    zuckerls = zuckerls.include_for_box.random(2)

    result = activities.to_a
    result.insert(3, zuckerls[0]) if zuckerls[0]
    result.insert(6, zuckerls[1]) if zuckerls[1]
    result.compact
  end

end
