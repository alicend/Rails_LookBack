class LoginInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :password, :email

  validates :password, presence: true, length: { minimum: 8, maximum: 255 }
  validates :email, presence: true, email: true
end
