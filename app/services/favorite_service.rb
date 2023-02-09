class FavoriteService

  def initialize(user, options = {})
    @user = user
    @options = options
  end

  def favorites

    # NIKOLA: how best to get favorites?
    # what about @user.favorites
    # how best to sort by favorite created_at date

    favorites = []
    favorites += User.joins(:favorite_users).where(favorite_users: {user: @user})
    favorites += CoopDemand.joins(:favorites).where(favorites: {user: @user})
    favorites += CrowdCampaign.joins(:favorites).where(favorites: {user: @user})
    favorites += Location.joins(:favorites).where(favorites: {user: @user})
    favorites += Meeting.joins(:favorites).where(favorites: {user: @user})
    favorites += RoomDemand.joins(:favorites).where(favorites: {user: @user})
    favorites += RoomOffer.joins(:favorites).where(favorites: {user: @user})
    favorites += ToolDemand.joins(:favorites).where(favorites: {user: @user})
    favorites += ToolOffer.joins(:favorites).where(favorites: {user: @user})
    favorites += Zuckerl.joins(:favorites).where(favorites: {user: @user})

    # Takes created at from record, not favorite created_at ... hmm
    favorites = favorites.sort_by(&:created_at)

    Kaminari.paginate_array(favorites).page(@options[:page]).per(@options[:per_page] || 15)
  end

  private

end
