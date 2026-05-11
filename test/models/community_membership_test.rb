require "test_helper"

class CommunityMembershipTest < ActiveSupport::TestCase
  setup do
    @alice     = users(:one)
    @bob       = users(:two)
    @community = communities(:one)
    @charlie   = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
  end

  test "valid with member role" do
    assert CommunityMembership.new(user: @charlie, community: @community, role: "member").valid?
  end

  test "valid with admin role" do
    assert CommunityMembership.new(user: @charlie, community: @community, role: "admin").valid?
  end

  test "invalid with unknown role" do
    assert_not CommunityMembership.new(user: @charlie, community: @community, role: "owner").valid?
  end

  test "invalid without role" do
    assert_not CommunityMembership.new(user: @charlie, community: @community, role: nil).valid?
  end

  test "duplicate user and community pair is invalid" do
    assert_not CommunityMembership.new(user: @alice, community: @community, role: "member").valid?
  end

  test "same user can join a different community" do
    other = communities(:two)
    assert CommunityMembership.new(user: @alice, community: other, role: "member").valid?
  end

  test "belongs to user" do
    assert_equal @alice, community_memberships(:one).user
  end

  test "belongs to community" do
    assert_equal @community, community_memberships(:one).community
  end
end
