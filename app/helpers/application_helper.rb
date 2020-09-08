module ApplicationHelper

  def link_to_more_info
    blog_url = 'https://blog.imgraetzl.at/services/'
    icon = 'icon-lightbulb'
    use = content_tag(:use, nil, { 'xlink:href' => "##{icon}" })
    link_to blog_url, target: '_blank' do
      concat content_tag(:svg, use, class: icon)
      concat "Mehr Infos"
    end
  end

  def active_link_to(*args, &block)
    if block_given?
      name = capture(&block)
      options = args[0] || {}
      html_options = args[1] || {}
    else
      name = args[0]
      options = args[1] || {}
      html_options = args[2] || {}
    end

    url = url_for(options)
    html_options[:class] = ['active', html_options[:class]] if current_page?(url)
    link_to(name, url, html_options)
  end

  def form_errors_for(target, name=nil)
    if target.errors.any?
      name ||= target.model_name.human
      render('errors', target: target, name: name)
    end
  end

  def icon_tag(name)
    "<svg class='icon-#{name} icon'><use xlink:href='#icon-#{name}'></use></svg>".html_safe
  end

  def icon_with_badge(icon_name, number, options = {})
    options[:class] = [options[:class], 'icon-with-badge']
    content_tag(:div, options) do
      icon_tag(icon_name) +
      content_tag(:div, number > 0 ? number : nil, class: 'icon-badge')
    end
  end

end
