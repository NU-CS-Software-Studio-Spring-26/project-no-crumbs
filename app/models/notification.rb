# Represents an in-app notification sent to a user when activity occurs.
#
# Notifications are polymorphic — the +notifiable+ can be a Friendship, Post,
# Comment, or Rsvp depending on the action type. An email is also dispatched
# if the recipient has email notifications enabled.
class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor,     class_name: "User"
  belongs_to :notifiable, polymorphic: true

  validates :action, inclusion: { in: %w[friend_request friend_accepted comment post_like rsvp] }

  # Notifications the recipient has not yet read.
  scope :unread,  -> { where(read_at: nil) }

  # Notifications ordered most-recent first.
  scope :recent,  -> { order(created_at: :desc) }

  # Creates a notification and optionally sends a delivery email.
  # No-ops if the actor and recipient are the same user.
  def self.create_notification(action:, recipient:, actor:, notifiable:)
    return if recipient == actor
    notification = create!(action: action, recipient: recipient, actor: actor, notifiable: notifiable)
    NotificationMailer.notification_email(notification).deliver_later if recipient.email_notifications_enabled?
    notification
  end
end
