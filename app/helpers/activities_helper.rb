module ActivitiesHelper
  def render_activity(activity)
    options = {}
    case activity.key
    when /\w*\.comment/
      options[:comment] = activity.trackable.comments.last
    # when /\w*\.go_to/
    #   options[:participant] = activity.owner
    end
    render activity.trackable, *options
  end
end
