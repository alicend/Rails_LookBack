class DeleteTaskInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :id

  validates :id, presence: true, numericality: { only_integer: true }
end
