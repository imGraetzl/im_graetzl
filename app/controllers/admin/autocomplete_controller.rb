module Admin
  class AutocompleteController < ::ApplicationController
    before_action :authenticate_admin_user!

    def show
      query = params[:q].to_s.downcase.strip
      terms = query.split
      return render json: [] if terms.empty?

      case params[:resource]
      when "users"
        render json: autocomplete_users(terms)
      when "locations"
        render json: autocomplete_locations(terms)
      else
        head :bad_request
      end
    end

    private

    def autocomplete_users(terms)
      sql_conditions = terms.map {
        "LOWER(users.first_name || ' ' || users.last_name || ' ' || users.username || ' ' || users.email) LIKE ?"
      }.join(" AND ")
      sql_params = terms.map { |term| "%#{term}%" }

      scope = case params[:scope]
              when 'with_locations'
                User.registered.joins(:locations).distinct
              when 'with_meetings'
                User.registered.where(
                  "EXISTS (SELECT 1 FROM meetings WHERE meetings.user_id = users.id)"
                )
              when 'with_room_demands'
                User.registered.joins(:room_demands).distinct
              when 'with_room_offers'
                User.registered.joins(:room_offers).distinct
              when 'with_coupon_histories'
                User.registered.joins(:coupon_histories).distinct
              else
                User.registered
              end

      scope
        .where(sql_conditions, *sql_params)
        .order(:first_name, :last_name)
        .limit(10)
        .map do |u|
          {
            id: u.id,
            region: u.region.name,
            image_url: u.avatar_url(:thumb).presence || ActionController::Base.helpers.asset_path('fallbacks/user_avatar.png'),
            username: u.username,
            full_name: u.full_name,
            autocomplete_display_name: u.full_name_with_username,
            email: u.email
          }
        end
    end

    def autocomplete_locations(terms)
      sql_conditions = terms.map {
        "LOWER(locations.name || ' ' || users.last_name || ' ' || users.username || ' ' || users.email) LIKE ?"
      }.join(" AND ")
      sql_params = terms.map { |term| "%#{term}%" }

      Location.joins(:user)
              .where(sql_conditions, *sql_params)
              .order(:name)
              .limit(10)
              .map do |l|
                {
                  id: l.id,
                  region: l.region&.name,
                  image_url: l.avatar_url(:thumb).presence || ActionController::Base.helpers.asset_path('fallbacks/location.png'),
                  name: l.name,
                  autocomplete_display_name: l.user&.full_name_with_username
                }
              end
    end
  end
end
