require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  test "can create a friendship with valid attributes" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    friendship = Friendship.new(requester: alice, receiver: bob, status: "pending")
    assert friendship.save
  end

  test "status defaults to pending" do
    friendship = friendships(:one)
    assert_equal "accepted", friendship.status
  end

  test "status must be pending, accepted, or declined" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    friendship = Friendship.new(requester: alice, receiver: bob, status: "strangers")
    assert_not friendship.valid?
    assert friendship.errors[:status].any?
  end

  test "pending status is valid" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    friendship = Friendship.new(requester: alice, receiver: bob, status: "pending")
    assert friendship.valid?
  end

  test "accepted status is valid" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    friendship = Friendship.new(requester: alice, receiver: bob, status: "accepted")
    assert friendship.valid?
  end

  test "declined status is valid" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    friendship = Friendship.new(requester: alice, receiver: bob, status: "declined")
    assert friendship.valid?
  end

  test "duplicate friendship between same pair is invalid" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    Friendship.create!(requester: alice, receiver: bob, status: "pending")
    duplicate = Friendship.new(requester: alice, receiver: bob, status: "pending")
    assert_not duplicate.valid?
    assert duplicate.errors[:requester_id].any?
  end

  test "pending scope returns only pending friendships" do
    alice = users(:one)
    bob   = users(:two)
    Friendship.where(requester: alice, receiver: bob).or(Friendship.where(requester: bob, receiver: alice)).destroy_all
    f = Friendship.create!(requester: alice, receiver: bob, status: "pending")
    assert_includes Friendship.pending, f
  end

  test "accepted scope returns only accepted friendships" do
    friendship = friendships(:one)
    assert_includes Friendship.accepted, friendship
  end

  test "pending scope excludes accepted friendships" do
    friendship = friendships(:one)
    assert_not_includes Friendship.pending, friendship
  end

  test "requires a requester" do
    bob = users(:two)
    friendship = Friendship.new(receiver: bob, status: "pending")
    assert_not friendship.valid?
    assert friendship.errors[:requester].any?
  end

  test "requires a receiver" do
    alice = users(:one)
    friendship = Friendship.new(requester: alice, status: "pending")
    assert_not friendship.valid?
    assert friendship.errors[:receiver].any?
  end
end
