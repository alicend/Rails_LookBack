class CategoryInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :category

  validates :category, presence: true, length: { minimum: 1, maximum: 30 }
end
