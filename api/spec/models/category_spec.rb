require 'rails_helper'

RSpec.describe Category, type: :model do
  # バリデーションのテスト
  describe 'validations' do
    it 'is valid with a valid category name' do
      user_group = UserGroup.create(name: 'Example User Group')
      category = Category.new(category: 'Example Category', user_group: user_group)
      expect(category).to be_valid
    end

    it 'is invalid without a category name' do
      user_group = UserGroup.create(name: 'Example User Group')
      category = Category.new(category: nil, user_group: user_group)
      expect(category).not_to be_valid
    end

    it 'is invalid with a category name too short' do
      user_group = UserGroup.create(name: 'Example User Group')
      category = Category.new(category: '', user_group: user_group)
      expect(category).not_to be_valid
    end

    it 'is invalid with a category name too long' do
      user_group = UserGroup.create(name: 'Example User Group')
      category = Category.new(category: 'a' * 31, user_group: user_group)
      expect(category).not_to be_valid
    end
  end

  # アソシエーションのテスト
  describe 'associations' do
    it { should belong_to(:user_group) }
    it { should have_many(:tasks).dependent(:destroy) }
  end
end
