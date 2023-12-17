class UserGroup < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1, maximum: 30 }
end
