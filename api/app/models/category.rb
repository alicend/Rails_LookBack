class Category < ApplicationRecord
  belongs_to :user_group
  has_many :tasks, dependent: :destroy

  validates :category, presence: true, length: { minimum: 1, maximum: 30 }
end
