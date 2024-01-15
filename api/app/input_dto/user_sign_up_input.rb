class UserSignUpInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :username, :password, :email, :user_group

  validates :username, presence: true, length: { minimum: 1, maximum: 30 }
  validates :password, presence: true, length: { minimum: 8, maximum: 255 }
  validates :email, presence: true, email: true
  validates :user_group, presence: true, length: { minimum: 1, maximum: 30 }
end
