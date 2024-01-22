class UpdateCurrentUserGroupInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :user_group

  validates :user_group, presence: true, length: { minimum: 1, maximum: 30 }
end
