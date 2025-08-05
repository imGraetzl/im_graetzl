class ActivityStream
  def fetch(region, user, graetzl_ids = nil)
    activities = Activity.in(region).or(Activity.platform)
    activities = activities.joins(:activity_graetzls).where(activity_graetzls: { graetzl_id: graetzl_ids }).distinct if graetzl_ids

    if user.present?
      activities = activities.where(group_id: nil).or(activities.where(group_id: user.group_ids))
    else
      activities = activities.where(group_id: nil)
    end

    # activities = activities.includes(:subject, :child).order(id: :desc)
    activities = activities.includes(subject: :user, child: :user).order(id: :desc)
    activities
  end
end