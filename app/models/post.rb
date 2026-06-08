# Represents a meal post created by a user.
#
# Posts can optionally have a scheduled meal date, a location address,
# and a description. They support likes, comments, RSVPs, and can be
# shared into one or more communities.
class Post < ApplicationRecord
  include PgSearch::Model

  # Full-text search scope across title (weighted A) and description (weighted B).
  pg_search_scope :search_meals,
    against: { title: "A", description: "B" },
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.1 }
    }

  belongs_to :user
  has_many :community_posts, dependent: :destroy
  has_many :communities, through: :community_posts
  has_many :rsvps, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 2000, allow_blank: true }
  validates :address, length: { maximum: 255, allow_blank: true }
  validate :meal_date_not_in_past, if: :meal_date_changed?
  validate :meal_date_not_too_far_in_future

  # Posts whose meal date is in the future or has no date set.
  scope :active,   -> { where("meal_date IS NULL OR meal_date > ?", 36.hours.ago) }

  # Posts whose meal date has passed (more than 36 hours ago).
  scope :archived, -> { where("meal_date IS NOT NULL AND meal_date <= ?", 36.hours.ago) }

  # Returns true if the meal date has passed by more than 36 hours.
  def archived?
    meal_date.present? && meal_date <= 36.hours.ago
  end

  private

  # Prevents setting a meal date in the past when the date field changes.
  def meal_date_not_in_past
    if meal_date.present? && meal_date < Time.current
      errors.add(:meal_date, "must be in the future")
    end
  end

  # Prevents scheduling a meal more than 6 months out.
  def meal_date_not_too_far_in_future
    if meal_date.present? && meal_date > 6.months.from_now
      errors.add(:meal_date, "must be within the next 6 months")
    end
  end
end
