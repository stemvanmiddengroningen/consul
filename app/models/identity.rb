class Identity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }

  def self.first_or_create_from_oauth(auth)
    auth_uid = auth.try(:uid) || auth["ID"]
    auth_provider = auth.try(:provider) || auth["provider"]
    where(uid: auth_uid, provider: auth_provider).first_or_create
  end
end
