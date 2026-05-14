class CommunityPost < ApplicationRecord
  belongs_to :post
  belongs_to :community
end
