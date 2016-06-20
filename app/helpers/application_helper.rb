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
