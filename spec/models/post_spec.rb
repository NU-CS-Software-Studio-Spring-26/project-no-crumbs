require "rails_helper"

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with a title and future meal_date" do
      post = build(:post, user: user, meal_date: 1.day.from_now)
      expect(post).to be_valid
    end

    it "is invalid without a title" do
      post = build(:post, user: user, title: nil)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to be_present
    end

    it "is invalid when title exceeds 100 characters" do
      post = build(:post, user: user, title: "a" * 101)
      expect(post).not_to be_valid
      expect(post.errors[:title]).to be_present
    end

    it "is valid with no meal_date" do
      post = build(:post, user: user, meal_date: nil)
      expect(post).to be_valid
    end

    it "is invalid when meal_date is in the past" do
      post = build(:post, user: user, meal_date: 1.hour.ago)
      expect(post).not_to be_valid
      expect(post.errors[:meal_date]).to include("must be in the future")
    end

    it "is invalid when meal_date is more than 6 months away" do
      post = build(:post, user: user, meal_date: 7.months.from_now)
      expect(post).not_to be_valid
      expect(post.errors[:meal_date]).to include("must be within the next 6 months")
    end

    it "does not revalidate meal_date when updating other fields on a past meal" do
      post = build(:post, user: user, meal_date: 2.days.ago)
      post.save(validate: false)
      post.title = "Updated Title"
      expect(post).to be_valid
    end
  end

  describe "#archived?" do
    it "returns true when meal_date is more than 36 hours ago" do
      post = build(:post, user: user, meal_date: 37.hours.ago)
      post.save(validate: false)
      expect(post.archived?).to be true
    end

    it "returns false when meal_date is in the future" do
      post = create(:post, user: user, meal_date: 1.day.from_now)
      expect(post.archived?).to be false
    end

    it "returns false when meal_date is nil" do
      post = create(:post, user: user, meal_date: nil)
      expect(post.archived?).to be false
    end
  end

  describe ".active scope" do
    it "includes posts with a future meal_date" do
      post = create(:post, user: user, meal_date: 1.day.from_now)
      expect(Post.active).to include(post)
    end

    it "includes posts with no meal_date" do
      post = create(:post, user: user, meal_date: nil)
      expect(Post.active).to include(post)
    end

    it "excludes posts with a meal_date more than 36 hours ago" do
      post = build(:post, user: user, meal_date: 37.hours.ago)
      post.save(validate: false)
      expect(Post.active).not_to include(post)
    end
  end

  describe ".archived scope" do
    it "includes posts with a meal_date more than 36 hours ago" do
      post = build(:post, user: user, meal_date: 37.hours.ago)
      post.save(validate: false)
      expect(Post.archived).to include(post)
    end

    it "excludes posts with a future meal_date" do
      post = create(:post, user: user, meal_date: 1.day.from_now)
      expect(Post.archived).not_to include(post)
    end

    it "excludes posts with no meal_date" do
      post = create(:post, user: user, meal_date: nil)
      expect(Post.archived).not_to include(post)
    end
  end
end
