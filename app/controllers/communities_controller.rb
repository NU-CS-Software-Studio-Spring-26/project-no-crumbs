class CommunitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community, only: %i[show members destroy]

  def index
    @communities = if params[:q].present?
      Community.where("name ILIKE ?", "%#{params[:q].to_s.strip.first(100)}%").order(:name)
    else
      Community.order(:name)
    end
  end

  def show
    @posts = @community.member_posts.includes(:user)
    @membership = current_user.community_memberships.find_by(community: @community)
  end

  def members
    @members = @community.members.order(:username)
  end

  def new
    @community = Community.new
  end

  def create
    @community = Community.new(community_params)
    @community.creator = current_user
    if @community.save
      @community.community_memberships.create!(user: current_user, role: "admin")
      redirect_to @community, notice: "#{@community.name} created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    unless @community.admin?(current_user)
      redirect_to communities_path, alert: "Only the community admin can delete it."
      return
    end
    @community.destroy
    redirect_to communities_path, notice: "Community deleted."
  end

  private

  def set_community
    @community = Community.find(params[:id])
  end

  def community_params
    params.require(:community).permit(:name, :description)
  end
end
