require "test_helper"

class CommunityMembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice     = users(:one)
    @bob       = users(:two)
    @community = communities(:one)
    @charlie   = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
    sign_in @charlie
  end

  test "non-member can join a community" do
    assert_difference("CommunityMembership.count") do
      post community_membership_url(@community)
    end
    assert_redirected_to community_url(@community)
    assert @community.member?(@charlie)
  end

  test "joining assigns member role" do
    post community_membership_url(@community)
    membership = CommunityMembership.find_by!(user: @charlie, community: @community)
    assert_equal "member", membership.role
  end

  test "already a member cannot join again" do
    sign_out :user
    sign_in @bob
    assert_no_difference("CommunityMembership.count") do
      post community_membership_url(@community)
    end
    assert_redirected_to community_url(@community)
  end

  test "member can leave a community" do
    sign_out :user
    sign_in @bob
    assert_difference("CommunityMembership.count", -1) do
      delete community_membership_url(@community)
    end
    assert_redirected_to communities_path
    assert_not @community.member?(@bob)
  end

  test "sole admin cannot leave" do
    sign_out :user
    sign_in @alice
    assert_no_difference("CommunityMembership.count") do
      delete community_membership_url(@community)
    end
    assert_redirected_to community_url(@community)
  end

  test "non-member cannot leave" do
    assert_no_difference("CommunityMembership.count") do
      delete community_membership_url(@community)
    end
    assert_redirected_to community_url(@community)
  end

  test "unauthenticated user is redirected when joining" do
    sign_out :user
    post community_membership_url(@community)
    assert_redirected_to new_user_session_path
  end
end
