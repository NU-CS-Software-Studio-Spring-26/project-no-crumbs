# Represents a like on a likeable resource (Post or Comment).
#
# Uses a polymorphic association so the same model handles likes
# on both posts and comments. A user may only like a given resource once.
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  validates :user_id, uniqueness: { scope: [ :likeable_type, :likeable_id ] }
end
