class Friendship < ApplicationRecord
  belongs_to :requester, class_name: 'User'
  belongs_to :receiver,  class_name: 'User'

  validates :status, inclusion: { in: %w[pending accepted declined] }
  validates :requester_id, uniqueness: { scope: :receiver_id }

  scope :pending,  -> { where(status: 'pending') }
  scope :accepted, -> { where(status: 'accepted') }
end
