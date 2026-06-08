class CommunitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community, only: %i[show members edit update destroy]
  before_action :require_admin, only: %i[edit update]

  def index
    @query = params[:q].to_s.strip.first(100)
    collection = if @query.present?
      safe_query = ActiveRecord::Base.sanitize_sql_like(@query)
      Community.where("name ILIKE ?", "%#{safe_query}%").order(:name)
    else
      Community.order(:name)
    end
    @pagy, @communities = pagy(:offset, collection)
  end

  def show
    @pagy, @posts = pagy(:offset, @community.posts.includes(:user).order(created_at: :desc))
    @membership = current_user.community_memberships.find_by(community: @community)
  end

  def members
    @members = @community.members.order(:username)
  end

  def mine
    @communities = current_user.communities.order(:name)
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

  def edit
  end

  def update
    if @community.update(community_params)
      redirect_to @community, notice: "#{@community.name} updated!"
    else
      render :edit, status: :unprocessable_entity
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

  def require_admin
    unless @community.admin?(current_user)
      redirect_to @community, alert: "Only the community admin can do that."
    end
  end

  def community_params
    params.require(:community).permit(:name, :description, :image)
  end
end
