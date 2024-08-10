class User < ApplicationRecord
  has_many :transactions, dependent: :destroy
  has_many :wallets, dependent: :destroy

  before_save { self.email.downcase! }

  validates :username, presence: true,
                      uniqueness: { case_sensitive: false },
                      length: {minimum: 3, maximum: 25}
  VALID_EMAIL_REGEX = /.+\@.+\..+/i
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
end
