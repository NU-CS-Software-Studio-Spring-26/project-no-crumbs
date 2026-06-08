# Represents a community (group) that users can join and share meals into.
#
# Every community has a creator who automatically receives admin privileges.
# Members can be regular members or admins.
class Community < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user
  has_many :community_posts, dependent: :destroy
  has_many :posts, through: :community_posts

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 2..50 }
  validates :description, length: { maximum: 1000, allow_blank: true }

  # Returns true if the given user has any membership in this community.
  def member?(user)
    community_memberships.exists?(user: user)
  end

  # Returns true if the given user holds the admin role in this community.
  def admin?(user)
    community_memberships.exists?(user: user, role: "admin")
  end
end
