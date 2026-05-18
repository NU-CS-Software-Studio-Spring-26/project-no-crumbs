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

  # dietary restrictions
  test "dietary_restrictions defaults to empty array" do
    user = User.create!(username: "freshuser", email: "fresh@example.com", password: "password123")
    assert_equal [], user.dietary_restrictions
  end

  test "can save dietary restrictions" do
    @alice.update!(dietary_restrictions: [ "vegan", "gluten_free" ])
    assert_equal [ "vegan", "gluten_free" ], @alice.reload.dietary_restrictions
  end

  test "can clear dietary restrictions" do
    @alice.update!(dietary_restrictions: [ "vegan" ])
    @alice.update!(dietary_restrictions: [])
    assert_equal [], @alice.reload.dietary_restrictions
  end

  test "dietary restrictions persist across reloads" do
    @alice.update!(dietary_restrictions: [ "halal", "dairy_free" ])
    assert_equal [ "halal", "dairy_free" ], User.find(@alice.id).dietary_restrictions
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

  # avatar attachment
  test "avatar is not attached by default" do
    user = User.new(username: "noavatar", email: "noavatar@example.com", password: "password123")
    assert_not user.avatar.attached?
  end

  test "valid with a jpeg avatar" do
    @alice.avatar.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    assert @alice.valid?
  end

  test "valid with a png avatar" do
    @alice.avatar.attach(io: StringIO.new("fake"), filename: "photo.png", content_type: "image/png")
    assert @alice.valid?
  end

  test "invalid when avatar is not an image" do
    @alice.avatar.attach(io: StringIO.new("fake"), filename: "doc.pdf", content_type: "application/pdf")
    assert_not @alice.valid?
    assert @alice.errors[:avatar].any?
  end

  test "invalid when avatar exceeds 5MB" do
    @alice.avatar.attach(io: StringIO.new("x" * 6.megabytes), filename: "big.jpg", content_type: "image/jpeg")
    assert_not @alice.valid?
    assert @alice.errors[:avatar].any?
  end

  # from_omniauth
  def mock_auth(uid: "12345", email: "oauth@example.com", name: "OAuth User", nickname: nil, provider: "google_oauth2")
    OpenStruct.new(
      provider: provider,
      uid:      uid,
      info:     OpenStruct.new(email: email, name: name, nickname: nickname)
    )
  end

  test "from_omniauth creates a new user when no match exists" do
    auth = mock_auth
    assert_difference "User.count", 1 do
      user = User.from_omniauth(auth)
      assert user.persisted?
      assert_equal "google_oauth2", user.provider
      assert_equal "12345",  user.uid
      assert_equal "oauth@example.com", user.email
    end
  end

  test "from_omniauth returns existing user when provider and uid match" do
    @alice.update!(provider: "google_oauth2", uid: "12345")
    auth = mock_auth(uid: "12345", email: "alice@example.com")
    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal @alice, user
    end
  end

  test "from_omniauth links provider to existing user matched by email" do
    auth = mock_auth(uid: "99999", email: "alice@example.com")
    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal @alice, user
      assert_equal "google_oauth2", @alice.reload.provider
      assert_equal "99999",         @alice.reload.uid
    end
  end

  test "from_omniauth generates username from display name" do
    auth = mock_auth(email: "newperson@example.com", name: "Jane Doe")
    user = User.from_omniauth(auth)
    assert_equal "jane_doe", user.username
  end

  test "from_omniauth prefers nickname over name for username" do
    auth = mock_auth(email: "ghuser@example.com", name: "Real Name", nickname: "gh_handle")
    user = User.from_omniauth(auth)
    assert_equal "gh_handle", user.username
  end

  test "from_omniauth appends numeric suffix when username is taken" do
    User.create!(username: "jane_doe", email: "first@example.com", password: "password123")
    auth = mock_auth(email: "second@example.com", name: "Jane Doe")
    user = User.from_omniauth(auth)
    assert_equal "jane_doe_1", user.username
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

  # DB constraint tests — bypass model validations with update_column / save(validate: false)
  test "database enforces email NOT NULL constraint" do
    assert_raises(ActiveRecord::NotNullViolation) { @alice.update_column(:email, nil) }
  end

  test "database enforces username NOT NULL constraint" do
    assert_raises(ActiveRecord::NotNullViolation) { @alice.update_column(:username, nil) }
  end

  test "database rejects nil email even when model validations are skipped" do
    user = User.new(username: "nomail_db", email: nil, password: "password123")
    assert_raises(ActiveRecord::NotNullViolation) { user.save(validate: false) }
  end

  test "database rejects nil username even when model validations are skipped" do
    user = User.new(username: nil, email: "nousername_db@example.com", password: "password123")
    assert_raises(ActiveRecord::NotNullViolation) { user.save(validate: false) }
  end
end
