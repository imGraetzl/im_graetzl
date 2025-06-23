# app/controllers/admin/autocomplete_controller.rb
module Admin
  class Admin::AutocompleteController < ::ApplicationController

    before_action :authenticate_admin_user!

    ALLOWED_RESOURCES = {
      "users" => ->(q) {
        User.registered
          .where("LOWER(first_name || ' ' || last_name || ' ' || username || ' ' || email) LIKE ?", "%#{q}%")
          .order(:first_name, :last_name)
          .limit(10)
          .map do |u|
            image_url = u.avatar_url(:thumb).presence || ActionController::Base.helpers.asset_path('fallbacks/user_avatar.png')
            {
              id: u.id,
              image_url: image_url,
              username: u.username,
              full_name: "#{u.first_name} #{u.last_name}",
              email: u.email
            }
          end
      },
      "meetings" => ->(q) {
        Meeting.where("LOWER(title) LIKE ?", "%#{q}%")
               .limit(20)
               .map { |m| { id: m.id, name: "#{m.title} (#{m.starts_at.to_date})" } }
      }
    }.freeze

    def show
      resource = params[:resource]
      query = params[:q].to_s.downcase.strip

      if ALLOWED_RESOURCES.key?(resource)
        results = ALLOWED_RESOURCES[resource].call(query)
        render json: results
      else
        head :not_found
      end
    end
  end
end
