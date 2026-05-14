class Community < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :community_memberships, dependent: :destroy
  has_many :members, through: :community_memberships, source: :user
  has_many :community_posts, dependent: :destroy
  has_many :posts, through: :community_posts

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 2..50 }
  validates :description, length: { maximum: 1000, allow_blank: true }

  def member?(user)
    community_memberships.exists?(user: user)
  end

  def admin?(user)
    community_memberships.exists?(user: user, role: "admin")
  end

end
