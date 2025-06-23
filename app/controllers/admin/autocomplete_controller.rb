# app/controllers/admin/autocomplete_controller.rb
module Admin
  class AutocompleteController < ::ApplicationController
    before_action :authenticate_admin_user!

    def show
      return head :bad_request unless params[:resource] == "users"

      query = params[:q].to_s.downcase.strip
      terms = query.split

      if terms.empty?
        render json: []
        return
      end

      sql_conditions = terms.map {
        "LOWER(users.first_name || ' ' || users.last_name || ' ' || users.username || ' ' || users.email) LIKE ?"
      }.join(" AND ")
      sql_params = terms.map { |term| "%#{term}%" }

      scope = case params[:scope]
              when 'with_locations'
                User.registered.joins(:locations).distinct
              when 'with_meetings'
                User.registered.where(
                  <<~SQL
                    EXISTS (
                      SELECT 1 FROM meetings WHERE meetings.user_id = users.id
                    )
                  SQL
                )
              when 'with_room_demands'
                User.registered.joins(:room_demands).distinct
              when 'with_room_offers'
                User.registered.joins(:room_offers).distinct
              else
                User.registered
              end

      users = scope
                .where(sql_conditions, *sql_params)
                .order(:first_name, :last_name)
                .limit(10)
                .map do |u|
                  image_url = u.avatar_url(:thumb).presence || ActionController::Base.helpers.asset_path('fallbacks/user_avatar.png')
                  {
                    id: u.id,
                    region: u.region.name,
                    image_url: image_url,
                    username: u.username,
                    full_name: "#{u.first_name} #{u.last_name}",
                    email: u.email
                  }
                end

      render json: users
    end
  end
end
