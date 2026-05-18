class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [ :update, :destroy ]

  def index
    @pagy, @friends   = pagy(:offset, current_user.friends)
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
      redirect_back fallback_location: friendships_path, notice: "Friend request sent."
    else
      friendship = current_user.sent_friendships.new(receiver: receiver)
      if friendship.save
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
