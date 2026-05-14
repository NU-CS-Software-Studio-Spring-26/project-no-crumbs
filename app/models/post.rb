class Post < ApplicationRecord
  belongs_to :user
  has_many :community_posts, dependent: :destroy
  has_many :communities, through: :community_posts
  has_many :rsvps, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 2000, allow_blank: true }
  validate :meal_date_not_too_far_in_future

  scope :active,   -> { where("meal_date IS NULL OR meal_date > ?", 36.hours.ago) }
  scope :archived, -> { where("meal_date IS NOT NULL AND meal_date <= ?", 36.hours.ago) }

  def archived?
    meal_date.present? && meal_date <= 36.hours.ago
  end

  private

  def meal_date_not_too_far_in_future
    if meal_date.present? && meal_date > 6.months.from_now
      errors.add(:meal_date, "must be within the next 6 months")
    end
  end
end
