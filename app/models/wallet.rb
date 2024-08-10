class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true,
                    length: { minimum: 2, maximum: 20 }
end
