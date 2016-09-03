module ApplicationHelper
  def main_navigation(mobile=nil)
    case
    when @district
      render "nav_district#{'_mobile' if mobile}", district: @district
    when @graetzl || current_user.try(:graetzl)
      render "nav_graetzl#{'_mobile' if mobile}", graetzl: (@graetzl || current_user.graetzl)
    else
      render "nav_home#{'_mobile' if mobile}"
    end
  end

  def personal_navigation_for(user)
    render user ? 'nav_user' : 'nav_guest'
  end

  def link_to_more_info
    blog_url = 'http://blog.imgraetzl.at/services/'
    icon = 'icon-lightbulb'
    use = content_tag(:use, nil, { 'xlink:href' => "##{icon}" })
    link_to blog_url, target: '_blank' do
      concat content_tag(:svg, use, class: icon)
      concat "Mehr Infos"
    end
  end

  def filters_for(user, graetzl)
    render "graetzls/#{user ? 'users' : 'guests'}/filters", graetzl: graetzl
  end

  def graetzl_stream_for(user)
    render "graetzls/#{user ? 'users' : 'guests'}/stream"
  end

  def active?(path)
    current_page?(path) ? 'active' : ''
  end

  def graetzl_flag(graetzl)
    content_tag(:div, link_to(graetzl.name, [graetzl]), class: 'sideflag -R') if controller_name == 'districts'
  end

  def form_errors_for(target, name=nil)
    if target.errors.any?
      name ||= target.model_name.human
      render('errors', target: target, name: name)
    end
  end
end
