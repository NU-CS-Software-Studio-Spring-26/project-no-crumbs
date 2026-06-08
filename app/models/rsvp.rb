# Represents a user's RSVP to a meal post.
#
# A user may only RSVP once per post and cannot RSVP to a meal they created.
# Valid statuses are defined in STATUSES.
class Rsvp < ApplicationRecord
  belongs_to :post
  belongs_to :user

  # The set of permitted RSVP response values.
  STATUSES = %w[going maybe not_going].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :post_id, message: "has already RSVPed to this meal" }
  validate :not_own_meal

  private

  # Prevents a user from RSVPing to a meal they created.
  def not_own_meal
    errors.add(:base, "You can't RSVP to your own meal") if post&.user == user
  end
end
