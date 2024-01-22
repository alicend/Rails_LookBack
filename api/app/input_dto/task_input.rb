class TaskInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :id, :task, :description, :start_date, :estimate, :responsible, :status, :category

  validates :id, presence: true, numericality: { only_integer: true }
  validates :task, presence: true, length: { minimum: 1, maximum: 255 }
  validates :description, presence: true, length: { minimum: 1, maximum: 255 }
  validates :start_date, presence: true, length: { minimum: 1, maximum: 24 }
  validates :estimate, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 1000 }
  validates :responsible, presence: true, numericality: { only_integer: true }
  validates :status, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 4 }
  validates :category, presence: true, numericality: { only_integer: true }
end
