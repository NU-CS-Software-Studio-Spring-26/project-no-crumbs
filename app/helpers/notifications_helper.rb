module NotificationsHelper
  def notification_message(notification)
    actor = notification.actor.username
    case notification.action
    when "friend_request"  then "#{actor} sent you a friend request"
    when "friend_accepted" then "#{actor} accepted your friend request"
    when "comment"         then "#{actor} commented on your meal"
    when "post_like"       then "#{actor} liked your meal"
    when "rsvp"            then "#{actor} RSVP'd to your meal"
    end
  end

  def notification_icon(action)
    case action
    when "friend_request"  then "bi-person-plus-fill"
    when "friend_accepted" then "bi-people-fill"
    when "comment"         then "bi-chat-fill"
    when "post_like"       then "bi-heart-fill"
    when "rsvp"            then "bi-check-circle-fill"
    end
  end
end
