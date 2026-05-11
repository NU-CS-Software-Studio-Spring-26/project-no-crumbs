class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @meals_count   = Post.count
    @friends_count = Friendship.accepted.count
    @cooks_count   = User.count
    @tables_count  = Rsvp.where(status: "going").count
  end
end
