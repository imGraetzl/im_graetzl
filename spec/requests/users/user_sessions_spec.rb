require 'rails_helper'

RSpec.describe "User sessions", type: :request do
  describe "POST /users/login" do
    let(:password) { "securePass123" }
    let(:user) { create(:user, :confirmed, password:) }

    it "authenticates the user with valid credentials" do
      post user_session_path, params: {
        user: { login: user.email, password: password }
      }

      expect(response).to redirect_to(root_url)

      follow_redirect!

      # Prüfe, dass Devise/Warden den User korrekt erkannt hat
      warden_proxy = request.env["warden"]
      expect(warden_proxy).to be_authenticated(:user)
      expect(warden_proxy.user(:user)).to eq(user)
      expect(controller.current_user).to eq(user)
    end
  end
end
