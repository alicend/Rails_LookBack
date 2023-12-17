class Task < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :responsible, class_name: "User"
  belongs_to :category

  validates :task, presence: true, length: { minimum: 1, maximum: 30 }
  validates :description, presence: true, length: { minimum: 1, maximum: 255 }
  validates :status, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 4 }
  validates :estimate, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 1000 }, allow_nil: true
end
