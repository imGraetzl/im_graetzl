module ActivitiesHelper

  def appendix_path_for(parent)
    case parent.class.to_s
    when LocationPost.to_s
      location = parent.author
      [location.graetzl, location]
    when AdminPost.to_s
      parent
    else
      [parent.graetzl, parent]
    end
  end
end
