class TaskInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :ID, :Task, :Description, :StartDate, :Estimate, :Responsible, :Status, :Category

  validates :ID, presence: true, numericality: { only_integer: true }
  validates :Task, presence: true, length: { minimum: 1, maximum: 255 }
  validates :Description, presence: true, length: { minimum: 1, maximum: 255 }
  validates :StartDate, presence: true, length: { minimum: 1, maximum: 24 }
  validates :Estimate, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 1000 }
  validates :Responsible, presence: true, numericality: { only_integer: true }
  validates :Status, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 4 }
  validates :Category, presence: true, numericality: { only_integer: true }
end
