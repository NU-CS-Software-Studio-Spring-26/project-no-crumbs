require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    @post  = posts(:one)
  end

  # Fixtures load correctly
  test "fixtures are valid" do
    assert notifications(:friend_request).valid?
    assert notifications(:post_like).valid?
    assert notifications(:comment_read).valid?
  end

  # Scopes
  test "unread scope returns notifications with nil read_at" do
    assert_includes Notification.unread, notifications(:friend_request)
    assert_includes Notification.unread, notifications(:post_like)
    assert_not_includes Notification.unread, notifications(:comment_read)
  end

  test "recent scope orders by created_at descending" do
    first = Notification.recent.first
    assert first.created_at >= Notification.recent.last.created_at
  end

  # create_notification helper
  test "create_notification creates a record" do
    assert_difference "Notification.count" do
      Notification.create_notification(action: "post_like", recipient: @alice, actor: @bob, notifiable: @post)
    end
  end

  test "create_notification is a no-op when recipient equals actor" do
    assert_no_difference "Notification.count" do
      Notification.create_notification(action: "post_like", recipient: @alice, actor: @alice, notifiable: @post)
    end
  end

  test "create_notification sets all fields correctly" do
    notif = Notification.create_notification(action: "rsvp", recipient: @alice, actor: @bob, notifiable: @post)
    assert_equal @alice, notif.recipient
    assert_equal @bob,   notif.actor
    assert_equal @post,  notif.notifiable
    assert_equal "rsvp", notif.action
    assert_nil notif.read_at
  end

  # Validations
  test "invalid action is rejected" do
    notif = Notification.new(recipient: @alice, actor: @bob, notifiable: @post, action: "bogus")
    assert_not notif.valid?
    assert_includes notif.errors[:action], "is not included in the list"
  end

  test "valid actions are accepted" do
    %w[friend_request friend_accepted comment post_like rsvp].each do |action|
      notif = Notification.new(recipient: @alice, actor: @bob, notifiable: @post, action: action)
      assert notif.valid?, "expected #{action} to be valid"
    end
  end

  # Associations
  test "belongs to recipient and actor" do
    notif = notifications(:friend_request)
    assert_equal @alice, notif.recipient
    assert_equal @bob,   notif.actor
  end

  test "destroyed when recipient user is destroyed" do
    notif = Notification.create_notification(action: "rsvp", recipient: @alice, actor: @bob, notifiable: @post)
    @alice.destroy
    assert_not Notification.exists?(notif.id)
  end
end
