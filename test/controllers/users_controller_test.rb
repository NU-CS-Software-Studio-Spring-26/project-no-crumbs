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

  test "index profile links preserve current people page" do
    get users_url(page: 1)
    assert_select "a[href='#{user_path(@user, return_to: "/users?page=1")}']"
  end

  test "show back link uses return_to param when present" do
    get user_url(@user, return_to: "/users?page=3")
    assert_select "a[href='/users?page=3']", text: /Back/
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

  # profile stats — use clean users with no fixture RSVPs to avoid bleed-in
  # stats bar order: Meals Hosted (1st), Friends (2nd), Meals Attending (3rd), RSVPs Received (4th)
  test "rsvps_sent count appears on profile page" do
    fresh = User.create!(username: "statuser1", email: "statuser1@example.com", password: "password123")
    sign_in fresh
    meal = Post.create!(title: "Dinner", user: @user, meal_date: 1.day.from_now)
    Rsvp.create!(post: meal, user: fresh, status: "going")
    get user_url(fresh)
    assert_select ".profile-stats-bar .profile-stat:nth-child(3) .profile-stat-num", text: "1"
  end

  test "rsvps_sent excludes not_going rsvps" do
    fresh = User.create!(username: "statuser2", email: "statuser2@example.com", password: "password123")
    sign_in fresh
    meal = Post.create!(title: "Dinner", user: @user, meal_date: 1.day.from_now)
    Rsvp.create!(post: meal, user: fresh, status: "not_going")
    get user_url(fresh)
    assert_select ".profile-stats-bar .profile-stat:nth-child(3) .profile-stat-num", text: "0"
  end

  test "rsvps_received count appears on profile page" do
    fresh = User.create!(username: "statuser3", email: "statuser3@example.com", password: "password123")
    sign_in fresh
    meal = Post.create!(title: "My Meal", user: fresh, meal_date: 1.day.from_now)
    Rsvp.create!(post: meal, user: @user, status: "going")
    get user_url(fresh)
    assert_select ".profile-stats-bar .profile-stat:nth-child(4) .profile-stat-num", text: "1"
  end

  test "rsvps_received does not count rsvps on other users meals" do
    fresh = User.create!(username: "statuser4", email: "statuser4@example.com", password: "password123")
    sign_in fresh
    other_meal = Post.create!(title: "Not My Meal", user: @user, meal_date: 1.day.from_now)
    Rsvp.create!(post: other_meal, user: fresh, status: "going")
    get user_url(fresh)
    assert_select ".profile-stats-bar .profile-stat:nth-child(4) .profile-stat-num", text: "0"
  end

  test "profile page renders four stats" do
    get user_url(@user)
    assert_select ".profile-stats-bar"
    assert_select ".profile-stat", 4
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
