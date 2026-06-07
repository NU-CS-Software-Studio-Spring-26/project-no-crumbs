require "test_helper"

class CommunitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice     = users(:one)
    @bob       = users(:two)
    @community = communities(:one)
    @charlie   = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
    sign_in @alice
  end

  test "should get index" do
    get communities_url
    assert_response :success
  end

  test "index search filters by name" do
    get communities_url, params: { q: "NU" }
    assert_response :success
    assert_match "NU Class", response.body
    assert_no_match "Chicago Food Scene", response.body
  end

  test "index search returns empty state for no match" do
    get communities_url, params: { q: "zzznomatch" }
    assert_response :success
    assert_match "No results for", response.body
  end

  test "should get show" do
    get community_url(@community)
    assert_response :success
  end

  test "should get members page" do
    get members_community_url(@community)
    assert_response :success
  end

  test "members page lists community members" do
    get members_community_url(@community)
    assert_match @alice.username, response.body
    assert_match @bob.username, response.body
  end

  test "should get new" do
    get new_community_url
    assert_response :success
  end

  test "should create community and add creator as admin" do
    assert_difference("Community.count") do
      post communities_url, params: { community: { name: "New Group", description: "A test group" } }
    end
    community = Community.find_by!(name: "New Group")
    assert_redirected_to community_url(community)
    assert community.admin?(@alice)
  end

  test "create with blank name re-renders form" do
    assert_no_difference("Community.count") do
      post communities_url, params: { community: { name: "", description: "oops" } }
    end
    assert_response :unprocessable_entity
  end

  test "create with duplicate name re-renders form" do
    assert_no_difference("Community.count") do
      post communities_url, params: { community: { name: "NU Class of '26", description: "dupe" } }
    end
    assert_response :unprocessable_entity
  end

  test "admin can destroy community" do
    assert_difference("Community.count", -1) do
      delete community_url(@community)
    end
    assert_redirected_to communities_path
  end

  test "non-admin cannot destroy community" do
    sign_out :user
    sign_in @bob
    assert_no_difference("Community.count") do
      delete community_url(@community)
    end
    assert_redirected_to communities_path
  end

  test "unauthenticated user is redirected from index" do
    sign_out :user
    get communities_url
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user is redirected from show" do
    sign_out :user
    get community_url(@community)
    assert_redirected_to new_user_session_path
  end

  test "should get my communities" do
    get mine_communities_url
    assert_response :success
  end

  test "my communities shows communities the user has joined" do
    get mine_communities_url
    assert_match "NU Class of &#x27;26", response.body
  end

  test "my communities excludes communities the user has not joined" do
    get mine_communities_url
    assert_no_match "Chicago Food Scene", response.body
  end

  test "my communities shows empty state when user has no communities" do
    sign_out :user
    sign_in @charlie
    get mine_communities_url
    assert_match "haven&#x27;t joined", response.body
  end

  test "unauthenticated user is redirected from my communities" do
    sign_out :user
    get mine_communities_url
    assert_redirected_to new_user_session_path
  end
end
