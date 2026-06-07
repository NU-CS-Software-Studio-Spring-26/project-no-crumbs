class NotificationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :unsubscribe ]
  before_action :set_notification, only: [ :mark_read ]

  def index
    @notifications = current_user.notifications.includes(:actor, :notifiable).recent
  end

  def unsubscribe
    user = User.find_signed(params[:token], purpose: :unsubscribe_notifications)
    if user
      user.update!(email_notifications_enabled: false)
      redirect_to root_path, notice: "You've been unsubscribed from email notifications."
    else
      redirect_to root_path, alert: "That unsubscribe link has expired or is invalid."
    end
  end

  def mark_read
    @notification.update!(read_at: Time.current) if @notification.read_at.nil?
    redirect_to notification_target_path(@notification)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  end

  def notification_target_path(notification)
    case notification.action
    when "friend_request", "friend_accepted" then friendships_path
    when "comment"                            then post_path(notification.notifiable.post)
    when "post_like"                          then post_path(notification.notifiable.likeable)
    when "rsvp"                               then post_path(notification.notifiable.post)
    end
  end
end
