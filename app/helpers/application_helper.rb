module ApplicationHelper

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
    "<svg class='icon-#{name} icon #{options[:class]}'><use xlink:href='/assets/icons.svg#icon-#{name}'></use></svg>".html_safe
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

end
