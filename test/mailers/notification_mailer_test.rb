require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  setup do
    @alice = users(:one)
    @bob   = users(:two)
    ActionMailer::Base.deliveries.clear
  end

  # --- Subject lines ---

  test "friend_request email has correct subject and recipient" do
    mail = NotificationMailer.notification_email(notifications(:friend_request))
    assert_equal "bob sent you a friend request", mail.subject
    assert_equal [ @alice.email ], mail.to
  end

  test "friend_accepted email has correct subject" do
    notif = Notification.new(action: "friend_accepted", recipient: @alice, actor: @bob,
                             notifiable: friendships(:one))
    mail = NotificationMailer.notification_email(notif)
    assert_equal "bob accepted your friend request", mail.subject
  end

  test "post_like email has correct subject" do
    like  = Like.create!(user: @bob, likeable: posts(:one))
    notif = Notification.new(action: "post_like", recipient: @alice, actor: @bob, notifiable: like)
    mail  = NotificationMailer.notification_email(notif)
    assert_equal "bob liked your meal", mail.subject
  end

  test "comment email has correct subject" do
    mail = NotificationMailer.notification_email(notifications(:comment_read))
    assert_equal "bob commented on your meal", mail.subject
  end

  test "rsvp email has correct subject" do
    notif = Notification.new(action: "rsvp", recipient: @alice, actor: @bob,
                             notifiable: rsvps(:one))
    mail = NotificationMailer.notification_email(notif)
    assert_equal "bob RSVP'd to your meal", mail.subject
  end

  # --- From address ---

  test "email is sent from the notifications address" do
    mail = NotificationMailer.notification_email(notifications(:friend_request))
    assert_equal [ "notifications@no-crumbs.app" ], mail.from
  end

  # --- Body content ---

  test "HTML body contains actor username" do
    mail = NotificationMailer.notification_email(notifications(:friend_request))
    assert_match "bob", mail.html_part.body.to_s
  end

  test "text body contains actor username" do
    mail = NotificationMailer.notification_email(notifications(:friend_request))
    assert_match "bob", mail.text_part.body.to_s
  end

  test "HTML body contains unsubscribe link" do
    mail = NotificationMailer.notification_email(notifications(:friend_request))
    assert_match "unsubscribe", mail.html_part.body.to_s.downcase
  end

  test "text body contains unsubscribe URL" do
    mail = NotificationMailer.notification_email(notifications(:friend_request))
    assert_match "unsubscribe", mail.text_part.body.to_s.downcase
  end

  # --- Delivery via create_notification ---

  test "create_notification delivers email when recipient has notifications enabled" do
    @alice.update!(email_notifications_enabled: true)
    assert_emails 1 do
      Notification.create_notification(
        action: "friend_request", recipient: @alice, actor: @bob,
        notifiable: friendships(:one)
      )
    end
  end

  test "create_notification skips email when recipient has notifications disabled" do
    @alice.update!(email_notifications_enabled: false)
    assert_emails 0 do
      Notification.create_notification(
        action: "friend_request", recipient: @alice, actor: @bob,
        notifiable: friendships(:one)
      )
    end
  end

  test "create_notification skips email when actor equals recipient" do
    @alice.update!(email_notifications_enabled: true)
    assert_emails 0 do
      Notification.create_notification(
        action: "friend_request", recipient: @alice, actor: @alice,
        notifiable: friendships(:one)
      )
    end
  end
end
