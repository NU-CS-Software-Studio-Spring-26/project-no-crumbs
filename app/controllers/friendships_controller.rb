class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [ :update, :destroy ]

  def index
    @query = params[:q].to_s.strip
    friends_scope = if @query.present?
      current_user.friends.search_friends(@query)
    else
      current_user.friends
    end
    @pagy, @friends   = pagy(:offset, friends_scope)
    @pending_received = current_user.pending_friend_requests
    @pending_sent     = current_user.sent_friendships.pending
  end

  def create
    receiver   = User.find(params[:receiver_id])

    # If a declined friendship already exists between these two users, reuse it
    existing = Friendship.where(requester: current_user, receiver: receiver, status: "declined")
                         .or(Friendship.where(requester: receiver, receiver: current_user, status: "declined"))
                         .first

    if existing
      existing.update!(requester: current_user, receiver: receiver, status: "pending")
      Notification.create_notification(action: "friend_request", recipient: receiver, actor: current_user, notifiable: existing)
      redirect_back fallback_location: friendships_path, notice: "Friend request sent."
    else
      friendship = current_user.sent_friendships.new(receiver: receiver)
      if friendship.save
        Notification.create_notification(action: "friend_request", recipient: receiver, actor: current_user, notifiable: friendship)
        redirect_back fallback_location: friendships_path, notice: "Friend request sent."
      else
        redirect_back fallback_location: friendships_path, alert: "Could not send friend request."
      end
    end
  end

  def update
    unless @friendship.receiver == current_user
      return redirect_back fallback_location: friendships_path, alert: "Not authorized."
    end
    @friendship.update!(status: params[:status])
    if params[:status] == "accepted"
      Notification.create_notification(action: "friend_accepted", recipient: @friendship.requester, actor: current_user, notifiable: @friendship)
    end
    redirect_back fallback_location: friendships_path, notice: "Request #{params[:status]}."
  end

  def destroy
    unless @friendship.requester == current_user || @friendship.receiver == current_user
      return redirect_back fallback_location: friendships_path, alert: "Not authorized."
    end
    @friendship.destroy
    redirect_back fallback_location: friendships_path, notice: "Removed."
  end

  private

  def set_friendship
    @friendship = Friendship.find(params[:id])
  end
end
