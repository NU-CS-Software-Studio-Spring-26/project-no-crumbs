require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "can create a user with valid attributes" do
    user = User.new(username: "testuser", email: "test@example.com", bio: "Hi there", password: "password123")
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
    user = User.create!(username: "tempuser", email: "temp@example.com", password: "password123")
    user.posts.create!(title: "Test Post", description: "desc", meal_date: Time.now)
    post_count_before = Post.count
    user.destroy
    assert_equal post_count_before - 1, Post.count
  end

  test "email must be present" do
    user = User.new(username: "nomail", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email must be unique" do
    user = User.new(username: "dupe", email: "alice@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "email must have valid format" do
    user = User.new(username: "badmail", email: "not-an-email", password: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "password must be present" do
    user = User.new(username: "nopass", email: "nopass@example.com")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "password must be at least 6 characters" do
    user = User.new(username: "shortpass", email: "short@example.com", password: "abc")
    assert_not user.valid?
    assert user.errors[:password].any?
  end

  test "friend_with? returns true for accepted friendship" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.find_or_create_by!(requester: alice, receiver: bob) { |f| f.status = "accepted" }
    assert alice.friend_with?(bob)
    assert bob.friend_with?(alice)
  end

  test "friend_with? returns false when no friendship exists" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    assert_not alice.friend_with?(bob)
  end

  test "pending_friend_requests returns only pending received friendships" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    Friendship.create!(requester: bob, receiver: alice, status: "pending")
    assert_includes alice.pending_friend_requests.map(&:requester), bob
  end
end
