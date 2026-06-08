# Join model between User and Community.
#
# Each record represents a user's membership in a community and tracks
# their role (member or admin). A user may only have one membership per community.
class CommunityMembership < ApplicationRecord
  belongs_to :user
  belongs_to :community

  validates :role, inclusion: { in: %w[member admin] }
  validates :user_id, uniqueness: { scope: :community_id }
end
