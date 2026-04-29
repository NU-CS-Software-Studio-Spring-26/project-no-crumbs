class Post < ApplicationRecord
  belongs_to :user

  scope :active,   -> { where("meal_date IS NULL OR meal_date > ?", 36.hours.ago) }
  scope :archived, -> { where("meal_date IS NOT NULL AND meal_date <= ?", 36.hours.ago) }
end
