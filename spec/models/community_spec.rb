require "rails_helper"

RSpec.describe Community, type: :model do
  let(:community) { build(:community, creator: create(:user)) }

  def attach_image(content_type:, filename: "cover.png", bytes: "fake image bytes")
    community.image.attach(io: StringIO.new(bytes), filename: filename, content_type: content_type)
  end

  describe "image attachment" do
    it "is valid without an image" do
      expect(community).to be_valid
    end

    it "is valid with an acceptable image" do
      attach_image(content_type: "image/png")

      expect(community).to be_valid
    end

    it "is invalid with a non-image content type" do
      attach_image(content_type: "text/plain", filename: "cover.txt", bytes: "not an image")

      expect(community).not_to be_valid
      expect(community.errors[:image]).to include("must be a JPEG, PNG, WebP, or GIF")
    end

    it "is invalid when the image exceeds 5MB" do
      attach_image(content_type: "image/png")
      allow(community.image.blob).to receive(:byte_size).and_return(6.megabytes)

      expect(community).not_to be_valid
      expect(community.errors[:image]).to include("must be less than 5MB")
    end
  end
end
