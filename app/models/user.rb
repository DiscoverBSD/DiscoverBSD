class User < ApplicationRecord
  has_secure_token :auth_token

  validates :uid, presence: true, uniqueness: true
  validates :provider, presence: true

  def self.find_or_create_from_auth_hash(auth_hash)
    User.find_or_create_by(uid: auth_hash.uid, provider: auth_hash.provider)
  end
end
