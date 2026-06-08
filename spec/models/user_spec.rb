require "rails_helper"

RSpec.describe User, type: :model do
  describe "#google_account?" do
    it "is true for users created via Google sign-in" do
      user = build(:user, :google)
      expect(user.google_account?).to be true
    end

    it "is false for users who registered with email and password" do
      user = build(:user)
      expect(user.google_account?).to be false
    end
  end
end
