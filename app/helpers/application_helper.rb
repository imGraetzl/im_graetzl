module ApplicationHelper

  def current_domain
    request.host.split(".").last(2).first
  end

  def welocally_platform_host
    if Rails.env.production?
      "www.#{Rails.application.config.welocally_host}"
    else
      Rails.application.config.welocally_host
    end
  end

  def welocally_platform_url
    about_platform_url(host: welocally_platform_host)
  end

  def form_errors_for(target, name=nil)
    if target.errors.any?
      name ||= target.model_name.human
      render('errors', target: target, name: name)
    end
  end

  def icon_tag(name, options = {})
    "<svg class='icon-#{name} icon #{options[:class]}'><use xlink:href='/assets/icons_220125.svg#icon-#{name}'></use></svg>".html_safe
  end

  def icon_with_badge(icon_name, number, options = {})
    options[:class] = [options[:class], 'icon-with-badge']
    content_tag(:div, options) do
      icon_tag(icon_name) +
      content_tag(:div, number > 0 ? number : nil, class: 'icon-badge')
    end
  end

  def toggle_favorite_icon(favoritable, options = {})
    link_to icon_tag("favorite"), toggle_favorite_favorite_path(favoritable.id, favoritable.class),
      remote: true, method: 'post',
      title: 'Auf deine Merkliste setzen',
      id: "favorite_#{favoritable.class.name.underscore}_#{favoritable.id}",
      class: ["toggle-fav-ico #{options[:class]}", current_user&.has_favorite?(favoritable) ? '-faved' : '']
  end

  def toggle_admin_icon(subject, notification, options = {})
    link_to(icon_tag("gear"), 'javascript:',
      class: ["toggle-admin-ico #{options[:class]} jBoxTooltip"],
      data: { tooltip_id: "tt-admin_#{subject.class.name.underscore}_#{subject.id}" }
    ) +
    content_tag(:div, class: "jBoxHidden jBoxDropdown", id: "tt-admin_#{subject.class.name.underscore}_#{subject.id}") do
      link_to(notification_destroy_notification_path(notification.id), 
        method: :delete,
        remote: true,
        data: { confirm: "#{subject.class.model_name.human} aus den E-Mails löschen?" }) do
        icon_tag("cross") +
        content_tag(:div, "Aus E-Mails löschen", class: 'icontxt')
      end +
      link_to(messenger_start_thread_path(user_id: subject.user.id), target: "_blank") do
        icon_tag("speech-bubbles") +
        content_tag(:div, "Message an User", class: 'icontxt')
      end +
      link_to(subject_url(subject), target: "_blank") do
        icon_tag("link") +
        content_tag(:div, "#{subject.class.model_name.human} ansehen", class: 'icontxt')
      end +
      link_to(send("admin_#{subject.class.name.underscore.downcase}_path", subject), target: "_blank") do
        icon_tag("link") +
        content_tag(:div, "Im AdminTool ansehen", class: 'icontxt')
      end
    end
  end

  def messenger_button(user, options = {})
    link_to messenger_start_thread_path(user_id: user&.id),
      rel: 'nofollow',
      data: { label: options[:label] },
      title: "#{user&.first_name} im Messenger kontaktieren",
      id: "requestMessengerBtn",
      class: "btn-messenger #{options[:class]}" do
        icon_tag("speech-bubbles") +
        content_tag(:span, "Im Messenger kontaktieren", class: 'mobile') +
        content_tag(:span, "Nachricht senden", class: 'desktop')
    end
  end

  def subject_url(subject)
    case subject
    when Meeting
      polymorphic_url([subject.graetzl, subject])
    when Location
      polymorphic_url([subject.graetzl, subject])
    else
      polymorphic_url(subject)
    end
  end

  def pluralize_de(count, singular, plural)
    "#{count} #{count == 1 ? singular : plural}"
  end

end
