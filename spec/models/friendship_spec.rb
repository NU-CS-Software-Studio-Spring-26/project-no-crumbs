require "rails_helper"

RSpec.describe Friendship, type: :model do
  let(:requester) { create(:user) }
  let(:receiver)  { create(:user) }

  describe "validations" do
    it "is valid with a permitted status" do
      friendship = build(:friendship, requester: requester, receiver: receiver, status: "pending")
      expect(friendship).to be_valid
    end

    it "is invalid with an unrecognized status" do
      friendship = build(:friendship, requester: requester, receiver: receiver, status: "besties")
      expect(friendship).not_to be_valid
      expect(friendship.errors[:status]).to be_present
    end

    it "rejects a duplicate friendship request between the same pair" do
      create(:friendship, requester: requester, receiver: receiver)
      duplicate = build(:friendship, requester: requester, receiver: receiver)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:requester_id]).to be_present
    end

    it "allows a friendship in the other direction" do
      create(:friendship, requester: requester, receiver: receiver)
      reverse = build(:friendship, requester: receiver, receiver: requester)
      expect(reverse).to be_valid
    end
  end

  describe "permitted statuses" do
    %w[pending accepted declined].each do |status|
      it "accepts '#{status}' as a valid status" do
        friendship = build(:friendship, requester: requester, receiver: receiver, status: status)
        expect(friendship).to be_valid
      end
    end
  end

  describe "scopes" do
    it ".pending returns only pending friendships" do
      pending_friendship  = create(:friendship, requester: requester, receiver: receiver, status: "pending")
      other_receiver      = create(:user)
      accepted_friendship = create(:friendship, requester: requester, receiver: other_receiver, status: "accepted")

      expect(Friendship.pending).to include(pending_friendship)
      expect(Friendship.pending).not_to include(accepted_friendship)
    end

    it ".accepted returns only accepted friendships" do
      other_receiver      = create(:user)
      accepted_friendship = create(:friendship, requester: requester, receiver: other_receiver, status: "accepted")
      pending_friendship  = create(:friendship, requester: requester, receiver: receiver, status: "pending")

      expect(Friendship.accepted).to include(accepted_friendship)
      expect(Friendship.accepted).not_to include(pending_friendship)
    end
  end
end
