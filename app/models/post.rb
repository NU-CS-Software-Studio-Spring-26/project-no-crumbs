class Post < ApplicationRecord
  belongs_to :user
  has_many :rsvps, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  scope :active,   -> { where("meal_date IS NULL OR meal_date > ?", 36.hours.ago) }
  scope :archived, -> { where("meal_date IS NOT NULL AND meal_date <= ?", 36.hours.ago) }

  def archived?
    meal_date.present? && meal_date <= 36.hours.ago
  end
end
