class UpdateCurrentUserGroupInput
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :userGroup

  validates :userGroup, presence: true, length: { minimum: 1, maximum: 30 }
end
