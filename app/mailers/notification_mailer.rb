class NotificationMailer < ApplicationMailer
  def notification_email(notification)
    @notification = notification
    @recipient    = notification.recipient
    @actor        = notification.actor
    @action       = notification.action
    @target_url   = notification_target_url(notification)
    @unsubscribe_url = unsubscribe_notifications_url(
      token: @recipient.signed_id(purpose: :unsubscribe_notifications, expires_in: 30.days)
    )

    mail(to: @recipient.email, subject: email_subject)
  end

  private

  def email_subject
    actor = @actor.username
    case @action
    when "friend_request"  then "#{actor} sent you a friend request"
    when "friend_accepted" then "#{actor} accepted your friend request"
    when "comment"         then "#{actor} commented on your meal"
    when "post_like"       then "#{actor} liked your meal"
    when "rsvp"            then "#{actor} RSVP'd to your meal"
    end
  end

  def notification_target_url(notification)
    case notification.action
    when "friend_request", "friend_accepted"
      friendships_url
    when "comment"
      post_url(notification.notifiable.post)
    when "post_like"
      post_url(notification.notifiable.likeable)
    when "rsvp"
      post_url(notification.notifiable.post)
    end
  end
end
