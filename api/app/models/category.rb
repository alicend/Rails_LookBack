class Category < ApplicationRecord
  belongs_to :user_group

  validates :category, presence: true, length: { minimum: 1, maximum: 30 }
end
