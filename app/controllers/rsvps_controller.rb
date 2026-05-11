class RsvpsController < ApplicationController
  before_action :set_post
  before_action :authorize_rsvp!

  def create
    @rsvp = @post.rsvps.find_or_initialize_by(user: current_user)

    if @rsvp.status == params[:status]
      @rsvp.destroy
      @rsvp = nil
    else
      @rsvp.status = params[:status]
      @rsvp.save!
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @post }
    end
  end

  def destroy
    @rsvp = @post.rsvps.find_by(user: current_user)
    @rsvp&.destroy
    @rsvp = nil

    respond_to do |format|
      format.turbo_stream { render :create }
      format.html { redirect_to @post }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def authorize_rsvp!
    if @post.user == current_user
      redirect_to @post, alert: "You can't RSVP to your own meal."
    elsif @post.archived?
      redirect_to @post, alert: "This meal has already passed."
    end
  end
end
