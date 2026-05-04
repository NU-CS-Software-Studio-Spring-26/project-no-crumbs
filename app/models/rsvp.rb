class Rsvp < ApplicationRecord
  belongs_to :post
  belongs_to :user

  STATUSES = %w[going maybe not_going].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :user_id, uniqueness: { scope: :post_id, message: "has already RSVPed to this meal" }
  validate :not_own_meal

  private

  def not_own_meal
    errors.add(:base, "You can't RSVP to your own meal") if post&.user == user
  end
end
