require "rails_helper"

RSpec.describe UserGroup, type: :model do
  # バリデーションのテスト
  describe "バリデーション" do
    it "全ての項目が有効" do
      user_group = UserGroup.new(name: "Example Group")
      expect(user_group).to be_valid
    end

    it "名前がない場合は無効" do
      user_group = UserGroup.new(name: nil)
      expect(user_group).not_to be_valid
    end

    it "名前が０文字の場合は無効" do
      user_group = UserGroup.new(name: "")
      expect(user_group).not_to be_valid
    end

    it "名前が31文字以上の場合は無効" do
      user_group = UserGroup.new(name: "a" * 31)
      expect(user_group).not_to be_valid
    end
  end

  # アソシエーションのテスト
  describe "アソシエーション" do
    it "多数のユーザーを持ち、ユーザーグループが削除されるとユーザーも削除される" do
      should have_many(:users).dependent(:destroy)
    end

    it "多数のカテゴリーを持ち、ユーザーグループが削除されるとカテゴリーも削除される" do
      should have_many(:categories).dependent(:destroy)
    end
  end
end
