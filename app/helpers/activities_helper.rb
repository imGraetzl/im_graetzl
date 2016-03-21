module ActivitiesHelper
  def render_activity(activity)
    appendix = {}
    case activity.key
    when /\w*\.comment/
      appendix[:comment] = activity.trackable.comments.last
    when /\w*\.go_to/
      appendix[:participant] = activity.owner
    end
    render activity.trackable, appendix: appendix
  end

  def appendix_path_for(parent)
    case parent.class.to_s
    when LocationPost.to_s
      location = parent.author
      [location.graetzl, location]
    else
      [parent.graetzl, parent]
    end
  end
end
