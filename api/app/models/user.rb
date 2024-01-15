class User < ApplicationRecord
  belongs_to :user_group

  validates :name, presence: true, length: { minimum: 1, maximum: 30 }
  validates :email, presence: true, length: { maximum: 255 }, email: true, uniqueness: true

  has_secure_password
end
