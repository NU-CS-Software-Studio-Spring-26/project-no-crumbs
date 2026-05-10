class Community < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def member?(user)
    community_memberships.exists?(user: user)
  end

  def admin?(user)
    community_memberships.exists?(user: user, role: "admin")
  end

  def member_posts
    Post.where(user_id: members.ids).order(created_at: :desc)
  end
end
