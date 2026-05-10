require "test_helper"

class CommunityTest < ActiveSupport::TestCase
  setup do
    @alice     = users(:one)
    @bob       = users(:two)
    @community = communities(:one)
    @charlie   = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
  end

  test "valid with name and creator" do
    assert Community.new(name: "Test Group", creator: @charlie).valid?
  end

  test "invalid without name" do
    assert_not Community.new(creator: @alice).valid?
  end

  test "invalid with duplicate name" do
    assert_not Community.new(name: "NU Class of '26", creator: @charlie).valid?
  end

  test "name uniqueness is case-insensitive" do
    assert_not Community.new(name: "nu class of '26", creator: @charlie).valid?
  end

  test "belongs to creator" do
    assert_equal @alice, @community.creator
  end

  test "has many members through memberships" do
    assert_includes @community.members, @alice
    assert_includes @community.members, @bob
  end

  test "member? returns true for a member" do
    assert @community.member?(@alice)
    assert @community.member?(@bob)
  end

  test "member? returns false for a non-member" do
    assert_not @community.member?(@charlie)
  end

  test "admin? returns true for admin member" do
    assert @community.admin?(@alice)
  end

  test "admin? returns false for regular member" do
    assert_not @community.admin?(@bob)
  end

  test "admin? returns false for non-member" do
    assert_not @community.admin?(@charlie)
  end

  test "member_posts returns posts from members" do
    post = @alice.posts.create!(title: "Community Post", description: "test", meal_date: 1.day.from_now)
    assert_includes @community.member_posts, post
  end

  test "member_posts excludes posts from non-members" do
    post = @charlie.posts.create!(title: "Outsider Post", description: "test", meal_date: 1.day.from_now)
    assert_not_includes @community.member_posts, post
  end

  test "destroying community destroys memberships" do
    count_before = CommunityMembership.count
    @community.destroy
    assert CommunityMembership.count < count_before
  end
end
