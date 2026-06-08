require "rails_helper"

RSpec.describe Rsvp, type: :model do
  let(:host) { create(:user) }
  let(:guest) { create(:user) }
  let(:post) { create(:post, user: host) }

  describe "validations" do
    it "is valid with a permitted status" do
      rsvp = build(:rsvp, user: guest, post: post, status: "going")
      expect(rsvp).to be_valid
    end

    it "is invalid with an unrecognized status" do
      rsvp = build(:rsvp, user: guest, post: post, status: "yes_please")
      expect(rsvp).not_to be_valid
      expect(rsvp.errors[:status]).to be_present
    end

    it "rejects a duplicate RSVP from the same user to the same post" do
      create(:rsvp, user: guest, post: post, status: "going")
      duplicate = build(:rsvp, user: guest, post: post, status: "maybe")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to be_present
    end

    it "allows different users to RSVP to the same post" do
      other_guest = create(:user)
      create(:rsvp, user: guest, post: post)
      rsvp = build(:rsvp, user: other_guest, post: post)
      expect(rsvp).to be_valid
    end
  end

  describe "custom validation: not_own_meal" do
    it "is invalid when the host RSVPs to their own meal" do
      rsvp = build(:rsvp, user: host, post: post)
      expect(rsvp).not_to be_valid
      expect(rsvp.errors[:base]).to include("You can't RSVP to your own meal")
    end

    it "is valid when a different user RSVPs" do
      rsvp = build(:rsvp, user: guest, post: post)
      expect(rsvp).to be_valid
    end
  end

  describe "permitted statuses" do
    Rsvp::STATUSES.each do |status|
      it "accepts '#{status}' as a valid status" do
        rsvp = build(:rsvp, user: guest, post: post, status: status)
        expect(rsvp).to be_valid
      end
    end
  end
end
