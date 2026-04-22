class User < ApplicationRecord
  has_many :posts, -> { order(meal_date: :asc) }, dependent: :destroy
end
