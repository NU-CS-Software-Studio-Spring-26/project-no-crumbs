class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_likeable

  def create
    @like = @likeable.likes.find_by(user: current_user)

    if @like
      @like.destroy
      @like = nil
    else
      @like = @likeable.likes.create!(user: current_user)
    end

    @size = params[:size]&.to_sym || :normal

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @likeable }
    end
  end

  private

  def set_likeable
    if params[:comment_id]
      @post = Post.find(params[:post_id])
      @likeable = @post.comments.find(params[:comment_id])
    else
      @likeable = Post.find(params[:post_id])
    end
  end
end
