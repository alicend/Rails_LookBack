require 'rails_helper'

RSpec.describe User, type: :model do
  # ユーザーの有効性のテスト
  describe 'validations' do
    it 'is valid with valid attributes' do
      user_group = UserGroup.create(name: 'Example Group')
      user = User.new(name: 'John Doe', email: 'john@example.com', password: 'password', password_confirmation: 'password', user_group: user_group)
      expect(user).to be_valid
    end

    it 'is invalid without a name' do
      user_group = UserGroup.create(name: 'Example Group')
      user = User.new(name: nil, email: 'john@example.com', password: 'password', password_confirmation: 'password', user_group: user_group)
      expect(user).not_to be_valid
    end

    it 'is invalid without an email' do
      user_group = UserGroup.create(name: 'Example Group')
      user = User.new(name: 'John Doe', email: nil, password: 'password', password_confirmation: 'password', user_group: user_group)
      expect(user).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      user_group = UserGroup.create(name: 'Example Group')
      User.create(name: 'John Doe', email: 'john@example.com', password: 'password', password_confirmation: 'password', user_group: user_group)
      user = User.new(name: 'Jane Doe', email: 'john@example.com', password: 'password', password_confirmation: 'password', user_group: user_group)
      expect(user).not_to be_valid
    end

    it 'is invalid with a name too long' do
      user_group = UserGroup.create(name: 'Example Group')
      name = 'a' * 31
      user = User.new(name: name, email: 'john@example.com', password: 'password', password_confirmation: 'password', user_group: user_group)
      expect(user).not_to be_valid
    end

    it 'is invalid with an email too long' do
      user_group = UserGroup.create(name: 'Example Group')
      email = 'a' * 244 + '@example.com'
      user = User.new(name: 'John Doe', email: email, password: 'password', password_confirmation: 'password', user_group: user_group)
      expect(user).not_to be_valid
    end

  end

  # アソシエーションのテスト
  describe 'associations' do
    it { should belong_to(:user_group) }
    it { should have_many(:created_tasks).with_foreign_key('creator_id').dependent(:destroy).class_name('Task') }
    it { should have_many(:responsible_tasks).with_foreign_key('responsible_id').dependent(:destroy).class_name('Task') }
  end

  # パスワードの検証
  describe 'password' do
    it 'is valid with a password and password_confirmation' do
      user_group = UserGroup.create(name: 'Example Group')
      user = User.new(name: 'John Doe', email: 'john@example.com', password: 'password', password_confirmation: 'password', user_group: user_group)
      expect(user).to be_valid
    end

    it 'is invalid when password does not match confirmation' do
      user_group = UserGroup.create(name: 'Example Group')
      user = User.new(name: 'John Doe', email: 'john@example.com', password: 'password', password_confirmation: 'different', user_group: user_group)
      expect(user).not_to be_valid
    end
  end
end
