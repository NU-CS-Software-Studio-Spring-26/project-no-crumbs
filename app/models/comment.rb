# Represents a comment left by a user on a meal post.
#
# Comments can themselves be liked via the polymorphic Like association.
class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :body, presence: true, length: { maximum: 500 }

  has_many :likes, as: :likeable, dependent: :destroy
end
