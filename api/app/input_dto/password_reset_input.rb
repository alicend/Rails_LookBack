class PasswordResetInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :password

  validates :email, presence: true, email: true
  validates :password, presence: true, length: { minimum: 8, maximum: 255 }
end
