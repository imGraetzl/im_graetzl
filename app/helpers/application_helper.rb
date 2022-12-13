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

  def link_to_more_info
    blog_url = 'https://blog.imgraetzl.at/services/'
    icon = 'icon-lightbulb'
    use = content_tag(:use, nil, { 'xlink:href' => "##{icon}" })
    link_to blog_url, target: '_blank' do
      concat content_tag(:svg, use, class: icon)
      concat "Mehr Infos"
    end
  end

  def form_errors_for(target, name=nil)
    if target.errors.any?
      name ||= target.model_name.human
      render('errors', target: target, name: name)
    end
  end

  def icon_tag(name)
    "<svg class='icon-#{name} icon'><use xlink:href='#{asset_path("#{root_url}assets/icons.svg")}#icon-#{name}'></use></svg>".html_safe
  end

  def icon_with_badge(icon_name, number, options = {})
    options[:class] = [options[:class], 'icon-with-badge']
    content_tag(:div, options) do
      icon_tag(icon_name) +
      content_tag(:div, number > 0 ? number : nil, class: 'icon-badge')
    end
  end

end
