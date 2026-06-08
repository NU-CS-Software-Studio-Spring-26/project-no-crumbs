# Represents a directional friendship request between two users.
#
# The requester initiates the request; the receiver accepts or declines it.
# A pair of users can only have one Friendship record regardless of direction.
class Friendship < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver,  class_name: "User"

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validates :requester_id, uniqueness: { scope: :receiver_id }

  # Friendships that have been sent but not yet acted on.
  scope :pending,  -> { where(status: "pending") }

  # Friendships that have been accepted by the receiver.
  scope :accepted, -> { where(status: "accepted") }
end
