require "test_helper"

class FriendshipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    @charlie = User.create!(username: "charlie", email: "charlie@example.com", password: "password123")
    friendships(:one).destroy
    sign_in @alice
  end

  test "should get index" do
    get friendships_url
    assert_response :success
  end

  test "should send friend request" do
    assert_difference("Friendship.count") do
      post friendships_url, params: { receiver_id: @bob.id }
    end
    assert_redirected_to friendships_path
  end

  test "sending friend request from profile keeps return_to in redirect" do
    profile_url = user_url(@bob, return_to: "/users?page=2")
    assert_difference("Friendship.count") do
      post friendships_url, params: { receiver_id: @bob.id }, headers: { "HTTP_REFERER" => profile_url }
    end
    assert_redirected_to profile_url
  end

  test "sending a friend request creates a notification for the receiver" do
    assert_difference("Notification.count") do
      post friendships_url, params: { receiver_id: @bob.id }
    end
    notif = Notification.last
    assert_equal "friend_request", notif.action
    assert_equal @bob,   notif.recipient
    assert_equal @alice, notif.actor
  end

  test "should accept friend request" do
    friendship = Friendship.create!(requester: @bob, receiver: @alice, status: "pending")
    patch friendship_url(friendship), params: { status: "accepted" }
    assert_equal "accepted", friendship.reload.status
  end

  test "accepting a friend request creates a notification for the requester" do
    friendship = Friendship.create!(requester: @bob, receiver: @alice, status: "pending")
    assert_difference("Notification.count") do
      patch friendship_url(friendship), params: { status: "accepted" }
    end
    notif = Notification.last
    assert_equal "friend_accepted", notif.action
    assert_equal @bob,   notif.recipient
    assert_equal @alice, notif.actor
  end

  test "should decline friend request" do
    friendship = Friendship.create!(requester: @bob, receiver: @alice, status: "pending")
    patch friendship_url(friendship), params: { status: "declined" }
    assert_equal "declined", friendship.reload.status
  end

  test "declining a friend request does not create a notification" do
    friendship = Friendship.create!(requester: @bob, receiver: @alice, status: "pending")
    assert_no_difference("Notification.count") do
      patch friendship_url(friendship), params: { status: "declined" }
    end
  end

  test "cannot accept a request you did not receive" do
    friendship = Friendship.create!(requester: @alice, receiver: @bob, status: "pending")
    patch friendship_url(friendship), params: { status: "accepted" }
    assert_equal "pending", friendship.reload.status
  end

  test "should destroy friendship" do
    friendship = Friendship.create!(requester: @alice, receiver: @bob, status: "accepted")
    assert_difference("Friendship.count", -1) do
      delete friendship_url(friendship)
    end
  end

  test "cannot destroy a friendship you are not part of" do
    friendship = Friendship.create!(requester: @bob, receiver: @charlie, status: "accepted")
    assert_no_difference("Friendship.count") do
      delete friendship_url(friendship)
    end
  end

  test "resends declined friend request instead of creating duplicate" do
    Friendship.create!(requester: @alice, receiver: @bob, status: "declined")
    assert_no_difference("Friendship.count") do
      post friendships_url, params: { receiver_id: @bob.id }
    end
    assert_equal "pending", Friendship.find_by(requester: @alice, receiver: @bob).status
  end

  test "unauthenticated user is redirected from index" do
    sign_out :user
    get friendships_url
    assert_redirected_to new_user_session_path
  end
end
