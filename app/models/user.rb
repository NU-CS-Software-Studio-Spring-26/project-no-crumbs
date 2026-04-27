class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :posts, -> { order(meal_date: :asc) }, dependent: :destroy

  has_many :sent_friendships,     class_name: 'Friendship', foreign_key: :requester_id, dependent: :destroy
  has_many :received_friendships, class_name: 'Friendship', foreign_key: :receiver_id,  dependent: :destroy

  has_many :friends_as_requester, -> { where(friendships: { status: 'accepted' }) },
           through: :sent_friendships, source: :receiver
  has_many :friends_as_receiver,  -> { where(friendships: { status: 'accepted' }) },
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
end
