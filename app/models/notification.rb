class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor,     class_name: "User"
  belongs_to :notifiable, polymorphic: true

  validates :action, inclusion: { in: %w[friend_request friend_accepted comment post_like rsvp] }

  scope :unread,  -> { where(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  def self.create_notification(action:, recipient:, actor:, notifiable:)
    return if recipient == actor
    notification = create!(action: action, recipient: recipient, actor: actor, notifiable: notifiable)
    NotificationMailer.notification_email(notification).deliver_later if recipient.email_notifications_enabled?
    notification
  end
end
