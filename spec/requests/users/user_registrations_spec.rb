require 'rails_helper'
require 'cgi'
require 'uri'

RSpec.describe "User registrations", type: :request do
  describe "POST /users" do
    let(:graetzl) { create(:graetzl, neighborless: true) }
    let(:password) { "SecurePass123" }
    let(:registration_params) do
      {
        username: "newuser",
        first_name: "New",
        last_name: "User",
        email: "newuser@example.com",
        password:,
        graetzl_id: graetzl.id,
        terms_and_conditions: "1",
        business: "0"
      }
    end

    it "creates an inactive account and sends confirmation instructions" do
      expect do
        post registration_path, params: { user: registration_params }
      end.to change(User, :count).by(1)

      user = User.find_by!(email: registration_params[:email])

      expect(user).not_to be_confirmed
      expect(user.graetzl).to eq(graetzl)
      expect(response).to redirect_to(root_url)

      warden_proxy = request.env["warden"]
      expect(warden_proxy).not_to be_authenticated(:user)

      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries).not_to be_empty
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to contain_exactly(registration_params[:email])
      expect(mail.subject).to be_present
      expect(mail.body.encoded).to include("confirmation_token")
    end

    it "confirms the account when following the confirmation link" do
      post registration_path, params: { user: registration_params }
      user = User.find_by!(email: registration_params[:email])

      mail = ActionMailer::Base.deliveries.last
      confirmation_url = mail.body.encoded.match(%r{https?://[^"]+confirmation_token=[^"]+})&.[](0)
      expect(confirmation_url).to be_present
      token = CGI.parse(URI.parse(confirmation_url).query)["confirmation_token"].first

      expect(token).to be_present

      get confirmation_path(confirmation_token: token)

      expect(response).to redirect_to(root_url)

      follow_redirect!

      user.reload
      expect(user).to be_confirmed

      warden_proxy = request.env["warden"]
      expect(warden_proxy).to be_authenticated(:user)
      expect(warden_proxy.user(:user)).to eq(user)
      expect(controller.current_user).to eq(user)
    end
  end
end
