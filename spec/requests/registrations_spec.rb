require "rails_helper"

RSpec.describe "Password changes", type: :request do
  include Devise::Test::IntegrationHelpers

  describe "GET /users/edit (change password page)" do
    it "is accessible to users who registered with email and password" do
      sign_in create(:user)

      get edit_user_registration_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects Google-authenticated users back to their profile" do
      user = create(:user, :google)
      sign_in user

      get edit_user_registration_path

      expect(response).to redirect_to(edit_user_path(user))

      follow_redirect!
      expect(response.body).to include("Your account uses Google sign-in")
    end
  end
end
