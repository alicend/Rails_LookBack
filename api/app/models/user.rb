class User < ApplicationRecord
  belongs_to :user_group
  has_many :created_tasks, class_name: 'Task', foreign_key: 'creator_id', dependent: :destroy
  has_many :responsible_tasks, class_name: 'Task', foreign_key: 'responsible_id', dependent: :destroy


  validates :name, presence: true, length: { minimum: 1, maximum: 30 }
  validates :email, presence: true, length: { maximum: 255 }, email: true, uniqueness: true

  has_secure_password
end
