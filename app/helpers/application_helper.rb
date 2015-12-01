module ApplicationHelper
  def current_graetzl
    @graetzl || (current_user.graetzl if user_signed_in?)
  end

  def nav_context
    @district || @graetzl || (current_user.graetzl if user_signed_in?) || GuestUser.new
  end

  def nav_user
    current_user || GuestUser.new
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
