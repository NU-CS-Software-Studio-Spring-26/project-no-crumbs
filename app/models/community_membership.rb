class CommunityMembership < ApplicationRecord
  belongs_to :user
  belongs_to :community

  validates :role, inclusion: { in: %w[member admin] }
  validates :user_id, uniqueness: { scope: :community_id }
end
