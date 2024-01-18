class UpdateCurrentUserNameInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :username

  validates :username, presence: true, length: { minimum: 1, maximum: 30 }
end
