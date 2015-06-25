module ApplicationHelper
  def title(page_title)
    content_for(:title) { "#{page_title} | "}    
  end

  def activity_description(user, activity)
    puts activity.key
    case activity.key
    when 'post.create'
      "Neuer post von <a href=''>#{user.username if user}</a>".html_safe
    when 'post.comment'
      "Post von <a href=''>#{user.username if user}</a>".html_safe
    when 'meeting.create'
    when 'meeting.comment'
    when 'meeting.go_to'
    else
    end
    
  end
end