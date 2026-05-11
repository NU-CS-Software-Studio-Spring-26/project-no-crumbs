require "test_helper"

class LikeTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    @post  = posts(:one)
    @charlie = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
  end

  test "valid like on a post" do
    assert Like.new(user: @bob, likeable: @post).valid?
  end

  test "invalid without user" do
    assert_not Like.new(user: nil, likeable: @post).valid?
  end

  test "invalid without likeable" do
    assert_not Like.new(user: @bob, likeable: nil).valid?
  end

  test "duplicate like by same user on same post is invalid" do
    Like.create!(user: @bob, likeable: @post)
    assert_not Like.new(user: @bob, likeable: @post).valid?
  end

  test "different users can like the same post" do
    Like.create!(user: @bob, likeable: @post)
    assert Like.new(user: @charlie, likeable: @post).valid?
  end

  test "same user can like different posts" do
    other_post = Post.create!(title: "Tacos", description: "come eat", meal_date: 2.days.from_now, user: @alice)
    Like.create!(user: @bob, likeable: @post)
    assert Like.new(user: @bob, likeable: other_post).valid?
  end

  test "likes destroyed when post is destroyed" do
    like = Like.create!(user: @bob, likeable: @post)
    @post.destroy
    assert_nil Like.find_by(id: like.id)
  end

  test "likes destroyed when user is destroyed" do
    like = Like.create!(user: @charlie, likeable: @post)
    assert_difference "Like.count", -1 do
      @charlie.destroy
    end
    assert_nil Like.find_by(id: like.id)
  end

  test "post has_many likes" do
    assert_respond_to @post, :likes
  end

  test "user has_many likes" do
    assert_respond_to @bob, :likes
  end

  test "like belongs to user" do
    like = Like.create!(user: @bob, likeable: @post)
    assert_equal @bob, like.user
  end

  test "like belongs to likeable post" do
    like = Like.create!(user: @bob, likeable: @post)
    assert_equal @post, like.likeable
  end
end
