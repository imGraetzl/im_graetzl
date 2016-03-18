module GraetzlsHelper
  def filters_for(user, graetzl)
    render "graetzls/#{user ? 'users' : 'guests'}/filters", graetzl: graetzl
  end

  def graetzl_stream_for(user)
    render "graetzls/#{user ? 'users' : 'guests'}/stream"
  end
end
