require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  setup do
    @alice   = users(:one)
    @bob     = users(:two)
    @charlie = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
  end

  # Use alice+charlie (no fixture conflict) for validity tests
  test "valid with pending status" do
    assert Friendship.new(requester: @alice, receiver: @charlie, status: "pending").valid?
  end

  test "valid with accepted status" do
    assert Friendship.new(requester: @alice, receiver: @charlie, status: "accepted").valid?
  end

  test "valid with declined status" do
    assert Friendship.new(requester: @alice, receiver: @charlie, status: "declined").valid?
  end

  test "invalid with unknown status" do
    assert_not Friendship.new(requester: @alice, receiver: @charlie, status: "blocked").valid?
  end

  test "invalid without status" do
    assert_not Friendship.new(requester: @alice, receiver: @charlie, status: nil).valid?
  end

  test "duplicate requester and receiver pair is invalid" do
    Friendship.create!(requester: @alice, receiver: @charlie, status: "pending")
    assert_not Friendship.new(requester: @alice, receiver: @charlie, status: "pending").valid?
  end

  test "reverse pair is valid" do
    Friendship.create!(requester: @alice, receiver: @charlie, status: "pending")
    assert Friendship.new(requester: @charlie, receiver: @alice, status: "pending").valid?
  end

  # Fixture-based tests
  test "belongs to requester" do
    assert_equal @alice, friendships(:one).requester
  end

  test "belongs to receiver" do
    assert_equal @bob, friendships(:one).receiver
  end

  # Scope tests use charlie to avoid fixture conflict
  test "pending scope returns only pending friendships" do
    Friendship.create!(requester: @alice, receiver: @charlie, status: "pending")
    assert Friendship.pending.all? { |f| f.status == "pending" }
  end

  test "accepted scope returns only accepted friendships" do
    Friendship.create!(requester: @alice, receiver: @charlie, status: "accepted")
    assert Friendship.accepted.all? { |f| f.status == "accepted" }
  end

  test "accepted scope excludes pending friendships" do
    assert_not_includes Friendship.accepted, friendships(:one)
  end
end
