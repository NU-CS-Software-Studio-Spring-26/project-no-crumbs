# Represents a registered user of NoCrumbs.
#
# Users can post meals, befriend other users, join communities,
# leave comments and likes, and receive in-app notifications.
# Authentication is handled by Devise with support for Google and Discord OAuth.
class User < ApplicationRecord
  include PgSearch::Model

  # Full-text search scope across username (weighted A) and bio (weighted B).
  pg_search_scope :search_friends,
    against: { username: "A", bio: "B" },
    using: {
      tsearch: { prefix: true },
      trigram: { threshold: 0.1 }
    }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :discord ]

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

  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy

  has_many :sent_friendships,     class_name: "Friendship", foreign_key: :requester_id, dependent: :destroy
  has_many :received_friendships, class_name: "Friendship", foreign_key: :receiver_id,  dependent: :destroy

  has_many :friends_as_requester, -> { where(friendships: { status: "accepted" }) },
           through: :sent_friendships, source: :receiver
  has_many :friends_as_receiver,  -> { where(friendships: { status: "accepted" }) },
           through: :received_friendships, source: :requester

  # Returns all accepted friends regardless of who sent the original request.
  def friends
    User.where(id: friends_as_requester.ids + friends_as_receiver.ids)
  end

  # Returns incoming friendship requests that have not yet been accepted or declined.
  def pending_friend_requests
    received_friendships.pending
  end

  # Returns true if the given user is an accepted friend of this user.
  def friend_with?(user)
    friends.include?(user)
  end

  class << self
    # Finds or creates a user from an OmniAuth authentication payload.
    # Matches first by provider+uid, then by email. Creates a new record if neither matches.
    def from_omniauth(auth)
      user = find_by(provider: auth.provider, uid: auth.uid)
      return user if user

      user = find_by(email: auth.info.email)
      if user
        user.update(provider: auth.provider, uid: auth.uid)
        return user
      end

      create(
        provider: auth.provider,
        uid:      auth.uid,
        email:    auth.info.email,
        password: Devise.friendly_token[0, 20],
        username: generate_username_from(auth)
      )
    end

    private

    # Derives a unique, sanitized username from an OmniAuth profile.
    # Falls back to "user" if the resulting string is too short, then appends
    # a numeric suffix until the username is unique.
    def generate_username_from(auth)
      raw = auth.info.nickname || auth.info.name || auth.info.email.split("@").first
      base = raw.downcase
                .gsub(/[^a-z0-9_]/, "_")
                .gsub(/_+/, "_")
                .gsub(/\A_+|_+\z/, "")
                .slice(0, 28)
      base = "user" if base.length < 2

      candidate = base
      counter   = 1
      while exists?(username: candidate)
        candidate = "#{base}_#{counter}"
        counter  += 1
      end
      candidate
    end
  end

  private

  # Validates that an attached avatar is an accepted image type and under 5 MB.
  def avatar_acceptable
    unless avatar.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:avatar, "must be a JPEG, PNG, WebP, or GIF")
    end
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end
  end
end
