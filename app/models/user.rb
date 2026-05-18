class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :github, :discord ]

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

  class << self
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

  def avatar_acceptable
    unless avatar.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:avatar, "must be a JPEG, PNG, WebP, or GIF")
    end
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end
  end
end
