require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    sign_in @alice
  end

  # index
  test "should get index" do
    get notifications_url
    assert_response :success
  end

  test "unauthenticated user is redirected from index" do
    sign_out :user
    get notifications_url
    assert_redirected_to new_user_session_path
  end

  test "index only shows current user's notifications" do
    get notifications_url
    assert_response :success
    assigns_notifications = @alice.notifications.recent
    assigns_notifications.each { |n| assert_equal @alice, n.recipient }
  end

  # mark_read
  test "mark_read sets read_at and redirects" do
    notif = notifications(:friend_request)
    assert_nil notif.read_at
    patch mark_read_notification_url(notif)
    assert_nil notif.read_at  # original object not mutated
    assert_not_nil notif.reload.read_at
    assert_redirected_to friendships_path
  end

  test "mark_read is idempotent — does not overwrite existing read_at" do
    notif = notifications(:comment_read)
    original_read_at = notif.read_at
    patch mark_read_notification_url(notif)
    assert_equal original_read_at, notif.reload.read_at
  end

  test "cannot mark another user's notification as read" do
    other_notif = Notification.create_notification(
      action: "rsvp", recipient: @bob, actor: @alice, notifiable: posts(:one)
    )
    patch mark_read_notification_url(other_notif)
    assert_response :not_found
  end

  test "unauthenticated user cannot mark read" do
    sign_out :user
    patch mark_read_notification_url(notifications(:friend_request))
    assert_redirected_to new_user_session_path
  end

  # mark_all_read
  test "mark_all_read clears all unread notifications" do
    unread_count = @alice.notifications.unread.count
    assert unread_count > 0, "expected alice to have unread notifications from fixtures"
    patch mark_all_read_notifications_url
    assert_equal 0, @alice.notifications.unread.count
    assert_redirected_to notifications_path
  end

  test "mark_all_read only affects current user" do
    bob_notif = Notification.create_notification(
      action: "rsvp", recipient: @bob, actor: @alice, notifiable: posts(:one)
    )
    patch mark_all_read_notifications_url
    assert_nil bob_notif.reload.read_at
  end

  test "unauthenticated user cannot mark all read" do
    sign_out :user
    patch mark_all_read_notifications_url
    assert_redirected_to new_user_session_path
  end

  # unsubscribe
  test "valid token unsubscribes user and redirects to root" do
    sign_out :user
    @alice.update!(email_notifications_enabled: true)
    token = @alice.signed_id(purpose: :unsubscribe_notifications, expires_in: 30.days)
    get unsubscribe_notifications_url(token: token)
    assert_redirected_to root_path
    assert_not @alice.reload.email_notifications_enabled
  end

  test "invalid token redirects with alert" do
    sign_out :user
    get unsubscribe_notifications_url(token: "bogus")
    assert_redirected_to root_path
    assert_equal "That unsubscribe link has expired or is invalid.", flash[:alert]
  end

  test "unsubscribe does not require authentication" do
    sign_out :user
    token = @alice.signed_id(purpose: :unsubscribe_notifications, expires_in: 30.days)
    get unsubscribe_notifications_url(token: token)
    assert_response :redirect
  end
end
