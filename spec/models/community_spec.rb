require "rails_helper"

RSpec.describe Community, type: :model do
  let(:creator) { create(:user) }

  describe "image attachment" do
    it "is valid without an image" do
      community = build(:community, creator: creator)
      expect(community).to be_valid
    end

    it "is valid with an acceptable image" do
      community = build(:community, creator: creator)
      community.image.attach(
        io: StringIO.new("fake image bytes"),
        filename: "cover.png",
        content_type: "image/png"
      )
      expect(community).to be_valid
    end

    it "is invalid with a non-image content type" do
      community = build(:community, creator: creator)
      community.image.attach(
        io: StringIO.new("not an image"),
        filename: "cover.txt",
        content_type: "text/plain"
      )
      expect(community).not_to be_valid
      expect(community.errors[:image]).to include("must be a JPEG, PNG, WebP, or GIF")
    end

    it "is invalid when the image exceeds 5MB" do
      community = build(:community, creator: creator)
      community.image.attach(
        io: StringIO.new("x" * 1024),
        filename: "cover.png",
        content_type: "image/png"
      )
      allow(community.image.blob).to receive(:byte_size).and_return(6.megabytes)
      expect(community).not_to be_valid
      expect(community.errors[:image]).to include("must be less than 5MB")
    end
  end
end
