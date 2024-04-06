class ActivityStream

  def fetch(region, user, graetzl_ids = nil)
    activities = Activity.in(region).or(Activity.platform)
    if graetzl_ids
      activities = activities.joins(:activity_graetzls).where(activity_graetzls: {graetzl_id: graetzl_ids}).distinct
    end

    activities = activities.where("group_id IS NULL OR group_id IN (?)", user&.group_ids)
    activities.includes(:subject, :child).order(id: :desc)
  end

end
