module GraetzlsHelper
  def filters_for(user, graetzl)
    render "graetzls/#{user ? 'users' : 'guests'}/filters", graetzl: graetzl
  end
end
