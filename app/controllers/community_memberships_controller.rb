class CommunityMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_community

  def create
    if @community.member?(current_user)
      redirect_to @community, alert: "You're already a member."
      return
    end
    @community.community_memberships.create!(user: current_user, role: "member")
    redirect_to @community, notice: "Joined #{@community.name}!"
  end

  def destroy
    membership = current_user.community_memberships.find_by(community: @community)
    unless membership
      redirect_to @community, alert: "You're not a member."
      return
    end
    if membership.role == "admin" && @community.community_memberships.where(role: "admin").count == 1
      redirect_to @community, alert: "You're the only admin — transfer admin first or delete the community."
      return
    end
    membership.destroy
    redirect_to communities_path, notice: "Left #{@community.name}."
  end

  private

  def set_community
    @community = Community.find(params[:community_id])
  end
end
