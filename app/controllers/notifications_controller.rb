class NotificationsController < ApplicationController
  before_action :set_notification, only: [ :mark_read ]

  def index
    @notifications = current_user.notifications.includes(:actor, :notifiable).recent
  end

  def mark_read
    @notification.update!(read_at: Time.current) if @notification.read_at.nil?
    redirect_to notification_target_path(@notification)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: "All notifications marked as read."
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
