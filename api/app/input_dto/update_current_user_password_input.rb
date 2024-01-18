class UpdateCurrentUserPasswordInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :current_password, :new_password

  validates :current_password, presence: true, length: { minimum: 8, maximum: 255 }
  validates :new_password, presence: true, length: { minimum: 8, maximum: 255 }
end
