require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  # バリデーションのテスト
  describe 'validations' do
    it 'is valid with a valid name' do
      user_group = UserGroup.new(name: 'Example Group')
      expect(user_group).to be_valid
    end

    it 'is invalid without a name' do
      user_group = UserGroup.new(name: nil)
      expect(user_group).not_to be_valid
    end

    it 'is invalid with a name too short' do
      user_group = UserGroup.new(name: '')
      expect(user_group).not_to be_valid
    end

    it 'is invalid with a name too long' do
      user_group = UserGroup.new(name: 'a' * 31)
      expect(user_group).not_to be_valid
    end
  end

  # アソシエーションのテスト
  describe 'associations' do
    it { should have_many(:users).dependent(:destroy) }
    it { should have_many(:categories).dependent(:destroy) }
  end
end
