require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "can create a user with valid attributes" do
    user = User.new(username: "testuser", email: "test@example.com", bio: "Hi there")
    assert user.save
  end

  test "user has a username" do
    user = users(:one)
    assert_equal "alice", user.username
  end

  test "user has an email" do
    user = users(:one)
    assert_equal "alice@example.com", user.email
  end

  test "user has a bio" do
    user = users(:one)
    assert_not_nil user.bio
  end

  test "user has many posts" do
    user = users(:one)
    assert_respond_to user, :posts
  end

  test "deleting user destroys associated posts" do
    user = User.create!(username: "tempuser", email: "temp@example.com")
    user.posts.create!(title: "Test Post", description: "desc", meal_date: Time.now)
    post_count_before = Post.count
    user.destroy
    assert_equal post_count_before - 1, Post.count
  end
end
