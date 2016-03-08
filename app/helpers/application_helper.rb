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

  def active?(path)
    current_page?(path) ? 'active' : ''
  end
end
