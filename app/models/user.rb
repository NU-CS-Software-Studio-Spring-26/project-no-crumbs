class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  validate :avatar_acceptable, if: -> { avatar.attached? }

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { in: 2..30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" }
  validates :bio, length: { maximum: 500, allow_blank: true }

  has_many :posts, -> { order(meal_date: :asc) }, dependent: :destroy
  has_many :rsvps, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :community_memberships, dependent: :destroy
  has_many :communities, through: :community_memberships
  has_many :created_communities, class_name: "Community", foreign_key: :creator_id, dependent: :destroy

  has_many :sent_friendships,     class_name: "Friendship", foreign_key: :requester_id, dependent: :destroy
  has_many :received_friendships, class_name: "Friendship", foreign_key: :receiver_id,  dependent: :destroy

  has_many :friends_as_requester, -> { where(friendships: { status: "accepted" }) },
           through: :sent_friendships, source: :receiver
  has_many :friends_as_receiver,  -> { where(friendships: { status: "accepted" }) },
           through: :received_friendships, source: :requester

  def friends
    User.where(id: friends_as_requester.ids + friends_as_receiver.ids)
  end

  def pending_friend_requests
    received_friendships.pending
  end

  def friend_with?(user)
    friends.include?(user)
  end

  private

  def avatar_acceptable
    unless avatar.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:avatar, "must be a JPEG, PNG, WebP, or GIF")
    end
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end
  end
end
