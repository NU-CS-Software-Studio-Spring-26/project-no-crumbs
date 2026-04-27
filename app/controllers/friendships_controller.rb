class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [ :update, :destroy ]

  def index
    @friends          = current_user.friends
    @pending_received = current_user.pending_friend_requests
    @pending_sent     = current_user.sent_friendships.pending
  end

  def create
    receiver   = User.find(params[:receiver_id])
    friendship = current_user.sent_friendships.new(receiver: receiver)
    if friendship.save
      redirect_back fallback_location: friendships_path, notice: "Friend request sent."
    else
      redirect_back fallback_location: friendships_path, alert: "Could not send friend request."
    end
  end

  def update
    unless @friendship.receiver == current_user
      return redirect_back fallback_location: friendships_path, alert: "Not authorized."
    end
    @friendship.update!(status: params[:status])
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
