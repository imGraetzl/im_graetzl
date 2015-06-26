module ApplicationHelper
  def title(page_title)
    content_for(:title) { "#{page_title} | "}    
  end

  def entry_description(user, entry)
    case entry.class.name.demodulize.downcase
    when 'activity'
      case entry.key
      when 'post.create'
        "Neuer Post von <a href=''>#{user.username if user}</a>".html_safe
      when 'meeting.create'
        "<a href=''>#{user.username if user}</a> hat ein Treffen erstellt".html_safe
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