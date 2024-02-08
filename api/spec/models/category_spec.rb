require "rails_helper"

RSpec.describe Category, type: :model do
  # バリデーションのテスト
  describe "バリデーション" do
    it "有効なカテゴリ名がある場合は有効" do
      user_group = UserGroup.create!(name: "Example User Group")
      category = Category.new(category: "Example Category", user_group:)
      expect(category).to be_valid
    end

    it "カテゴリ名がない場合は無効" do
      user_group = UserGroup.create!(name: "Example User Group")
      category = Category.new(category: nil, user_group:)
      expect(category).not_to be_valid
    end

    it "カテゴリ名が0文字の場合は無効" do
      user_group = UserGroup.create!(name: "Example User Group")
      category = Category.new(category: "", user_group:)
      expect(category).not_to be_valid
    end

    it "カテゴリ名が長すぎる場合は無効" do
      user_group = UserGroup.create!(name: "Example User Group")
      category_name = "a" * 31
      category = Category.new(category: category_name, user_group:)
      expect(category).not_to be_valid
    end
  end

  # アソシエーションのテスト
  describe "アソシエーション" do
    it { should belong_to(:user_group) }
    it { should have_many(:tasks).dependent(:destroy) }
  end
end
