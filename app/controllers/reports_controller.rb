class ReportsController < ApplicationController
  before_action :authenticate_admin_user!

  def index
  end

  def mailchimp

    list_id = Rails.application.secrets.mailchimp_list_id
    gibbon = Gibbon::Request.new

    members = gibbon.lists(list_id).members.retrieve

    render json: members
  end

end
