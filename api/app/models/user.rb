class User < ApplicationRecord
  belongs_to :user_group

  validates :name, presence: true, length: { minimum: 1, maximum: 30 }
  validates :password, presence: true, length: { minimum: 8, maximum: 255 }
  validates :email, presence: true, length: { maximum: 255 }, email: true, uniqueness: true
end
