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
end
