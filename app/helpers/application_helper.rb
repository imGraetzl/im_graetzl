module ApplicationHelper
  def title(page_title)
    content_for(:title) { "#{page_title} | "}    
  end

  def current_graetzl
    @graetzl || (current_user.graetzl if user_signed_in?)
  end
  
  def default_district
    District.find_by_zip('1020')
  end

  def activity_description(user, entity)
    case entity.class.name.demodulize.downcase
    when 'activity'
      case entity.key
      when 'post.create'
        "Neuer Post von #{link_to user.username, user}".html_safe
      when 'meeting.create'
        "#{link_to user.username, user} hat ein Treffen erstellt".html_safe
      when 'meeting.go_to'
        "Treffen von #{link_to user.username, user} hat neue Teilnehmer".html_safe
      else
      end
    when 'post'
      "Post von #{link_to user.username, user}".html_safe
    when 'meeting'
      "Treffen von #{link_to user.username, user}".html_safe
    when 'comment'
      "Kommentar von #{link_to user.username, user}".html_safe
    else
    end    
  end
end