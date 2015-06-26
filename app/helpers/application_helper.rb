module ApplicationHelper
  def title(page_title)
    content_for(:title) { "#{page_title} | "}    
  end

  def activity_description(user, activity)
    case activity.class.name.demodulize.downcase
    when 'activity'
      case activity.key
      when 'post.create'
        "Neuer Post von <a href=''>#{user.username if user}</a>".html_safe
      when 'meeting.create'
        "<a href=''>#{user.username if user}</a> hat ein Treffen erstellt".html_safe
      when 'meeting.go_to'
        "Treffen von <a href=''>#{user.username if user}</a> hat neue Teilnehmer".html_safe
      else
      end
    when 'post'
      "Post von <a href=''>#{user.username if user}</a>".html_safe
    when 'meeting'
      "Treffen von <a href=''>#{user.username if user}</a>".html_safe
    when 'comment'
      "Kommentar von <a href=''>#{user.username if user}</a>".html_safe
    else
    end    
  end
end