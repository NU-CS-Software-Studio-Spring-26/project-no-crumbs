require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    # Remove fixture friendship so tests can create their own alice-bob pairs freely
    friendships(:one).destroy
  end

  test "can create a user with valid attributes" do
    user = User.new(username: "testuser", email: "test@example.com", bio: "Hi there", password: "password123")
    assert user.save
  end

  test "user has a username" do
    assert_equal "alice", @alice.username
  end

  test "user has an email" do
    assert_equal "alice@example.com", @alice.email
  end

  test "user has a bio" do
    assert_not_nil @alice.bio
  end

  # username length validation
  test "invalid when username is shorter than 2 characters" do
    user = User.new(username: "a", email: "short@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:username].any?
  end

  test "valid with username at exactly 2 characters" do
    user = User.new(username: "ab", email: "two@example.com", password: "password123")
    assert user.valid?
  end

  test "invalid when username exceeds 30 characters" do
    user = User.new(username: "a" * 31, email: "long@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:username].any?
  end

  test "valid with username at exactly 30 characters" do
    user = User.new(username: "a" * 30, email: "thirty@example.com", password: "password123")
    assert user.valid?
  end

  # username format validation
  test "invalid when username contains spaces" do
    user = User.new(username: "hello world", email: "space@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:username].any?
  end

  test "invalid when username contains special characters" do
    user = User.new(username: "user@name!", email: "special@example.com", password: "password123")
    assert_not user.valid?
    assert user.errors[:username].any?
  end

  test "valid with username containing letters numbers and underscores" do
    user = User.new(username: "user_123", email: "valid@example.com", password: "password123")
    assert user.valid?
  end

  # bio length validation
  test "invalid when bio exceeds 500 characters" do
    user = User.new(username: "biotest", email: "bio@example.com", password: "password123", bio: "a" * 501)
    assert_not user.valid?
    assert user.errors[:bio].any?
  end

  test "valid with bio at exactly 500 characters" do
    user = User.new(username: "biotest2", email: "bio2@example.com", password: "password123", bio: "a" * 500)
    assert user.valid?
  end

  test "valid without bio" do
    user = User.new(username: "nobio", email: "nobio@example.com", password: "password123")
    assert user.valid?
  end

  test "user has many posts" do
    assert_respond_to @alice, :posts
  end

  test "deleting user destroys associated posts" do
    user = User.create!(username: "tempuser", email: "temp@example.com", password: "password123")
    user.posts.create!(title: "Test Post", description: "desc", meal_date: 1.day.from_now)
    count_before = Post.count
    user.destroy
    assert_equal count_before - 1, Post.count
  end

  test "deleting user destroys associated friendships" do
    Friendship.create!(requester: @alice, receiver: @bob, status: "accepted")
    count_before = Friendship.count
    @alice.destroy
    assert_equal count_before - 1, Friendship.count
  end

  test "friends returns accepted friends" do
    Friendship.create!(requester: @alice, receiver: @bob, status: "accepted")
    assert_includes @alice.friends, @bob
    assert_includes @bob.friends, @alice
  end

  test "friends does not include pending requests" do
    Friendship.create!(requester: @alice, receiver: @bob, status: "pending")
    assert_not_includes @alice.friends, @bob
  end

  test "friend_with? returns true for accepted friend" do
    Friendship.create!(requester: @alice, receiver: @bob, status: "accepted")
    assert @alice.friend_with?(@bob)
  end

  test "friend_with? returns false for non-friend" do
    assert_not @alice.friend_with?(@bob)
  end

  test "friend_with? returns false for pending request" do
    Friendship.create!(requester: @alice, receiver: @bob, status: "pending")
    assert_not @alice.friend_with?(@bob)
  end

  test "pending_friend_requests returns pending received friendships" do
    f = Friendship.create!(requester: @bob, receiver: @alice, status: "pending")
    assert_includes @alice.pending_friend_requests, f
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
