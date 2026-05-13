require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should create user" do
    skip "User creation is handled by Devise registration"
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { bio: @user.bio, email: @user.email, username: @user.username } }
    assert_redirected_to user_url(@user, direct: 1)
  end

  test "should destroy user" do
    assert_difference("User.count", -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end

  # Authorization
  test "non-owner cannot edit another user's profile" do
    sign_in users(:two)
    get edit_user_url(@user)
    assert_redirected_to user_url(@user)
  end

  test "non-owner cannot update another user's profile" do
    sign_in users(:two)
    patch user_url(@user), params: { user: { username: "hacked" } }
    assert_redirected_to user_url(@user)
  end

  test "non-owner cannot destroy another user's account" do
    sign_in users(:two)
    assert_no_difference("User.count") do
      delete user_url(@user)
    end
    assert_redirected_to user_url(@user)
  end

  # Authentication
  test "unauthenticated user is redirected from index" do
    sign_out :user
    get users_url
    assert_redirected_to new_user_session_path
  end

  test "unauthenticated user is redirected from show" do
    sign_out :user
    get user_url(@user)
    assert_redirected_to new_user_session_path
  end

  # dietary restrictions
  test "can save dietary restrictions" do
    patch user_url(@user), params: { user: { dietary_restrictions: [ "vegan", "gluten_free" ] } }
    assert_equal [ "vegan", "gluten_free" ], @user.reload.dietary_restrictions
  end

  test "can clear dietary restrictions by submitting empty sentinel" do
    @user.update!(dietary_restrictions: [ "vegan" ])
    patch user_url(@user), params: { user: { dietary_restrictions: [ "" ] } }
    assert_equal [], @user.reload.dietary_restrictions
  end

  test "ignores blank values in dietary restrictions" do
    patch user_url(@user), params: { user: { dietary_restrictions: [ "", "nut_free" ] } }
    assert_equal [ "nut_free" ], @user.reload.dietary_restrictions
  end
end
